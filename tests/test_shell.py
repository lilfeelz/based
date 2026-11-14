import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class PrimitiveTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name)
        self.home = self.base / "home"
        self.home.mkdir()
        self.bin = self.base / "bin"
        self.bin.mkdir()
        self.env = dict(
            os.environ,
            HOME=str(self.home),
            PATH=f"{self.bin}:{ROOT / 'bin'}:{os.environ['PATH']}",
            BASED_CONFIG=str(self.home / ".config/based"),
            BASED_NVIM_CONFIG=str(self.home / ".config/nvim"),
        )

    def mock(self, name, body):
        p = self.bin / name
        p.write_text("#!/bin/sh\n" + body + "\n")
        p.chmod(0o755)

    def run_cmd(self, args, stdin=None):
        return subprocess.run(
            args,
            cwd=self.home,
            env=self.env,
            input=stdin,
            text=True,
            capture_output=True,
            check=True,
        )

    def test_w_lists_workspaces(self):
        (self.home / "Notes/topic").mkdir(parents=True)
        (self.home / "Workspaces/ctx/proj").mkdir(parents=True)
        out = self.run_cmd([str(ROOT / "bin/w")]).stdout.splitlines()
        self.assertIn("~", out)
        self.assertIn("~/Notes", out)
        self.assertIn("~/Notes/topic", out)
        self.assertIn("~/Workspaces/ctx/proj", out)

    def test_m_zmx_list_attach_detach_delete_and_pipe(self):
        self.env["BASED_MUX"] = "zmx"
        self.mock("zmx", 'printf "zmx:%s\\n" "$*"')
        proj = self.home / "Workspaces/ctx/demo"
        proj.mkdir(parents=True)
        self.assertEqual(
            self.run_cmd([str(ROOT / "bin/m"), "list"]).stdout.strip(),
            "zmx:list --short",
        )
        self.assertEqual(
            self.run_cmd(
                [str(ROOT / "bin/m"), "attach"], stdin="~/Workspaces/ctx/demo\n"
            ).stdout.strip(),
            "zmx:attach demo dvtm -m ^a",
        )
        self.assertEqual(
            self.run_cmd([str(ROOT / "bin/m"), "detach"]).stdout.strip(),
            "zmx:detach",
        )
        self.assertEqual(
            self.run_cmd(
                [str(ROOT / "bin/m"), "delete"], stdin="one\ntwo\n"
            ).stdout.splitlines(),
            ["zmx:kill one", "zmx:kill two"],
        )

    def test_m_rex_list_attach_delete(self):
        self.env["BASED_MUX"] = "rex"
        self.mock(
            "rex",
            'if [ "$1" = ls ]; then printf "ID NAME\\n1 alpha\\n"; else printf "rex:%s\\n" "$*"; fi',
        )
        self.assertEqual(
            self.run_cmd([str(ROOT / "bin/m"), "list"]).stdout.splitlines(),
            ["alpha"],
        )
        self.assertEqual(
            self.run_cmd([str(ROOT / "bin/m"), "attach", "alpha"]).stdout.strip(),
            "rex:attach alpha",
        )
        self.assertEqual(
            self.run_cmd([str(ROOT / "bin/m"), "delete", "alpha"]).stdout.strip(),
            "rex:kill alpha",
        )

    def test_d_lists_and_connects_hosts(self):
        ssh_cfg = self.base / "ssh_config"
        ssh_cfg.write_text("Host *\n  User j\nHost book pixel\n  HostName 10.0.0.1\n")
        self.env["SSH_CONFIG"] = str(ssh_cfg)
        self.mock("tailscale", "exit 1")
        self.mock("ssh", 'printf "ssh:%s\\n" "$*"')
        hosts = self.run_cmd([str(ROOT / "bin/d"), "list"]).stdout.splitlines()
        self.assertEqual(hosts, ["book", "pixel"])
        conn = self.run_cmd([str(ROOT / "bin/d")], stdin="pixel\n").stdout.strip()
        self.assertEqual(conn, "ssh:-t -- pixel")
        cmd = self.run_cmd([str(ROOT / "bin/d"), "book", "m", "list"]).stdout.strip()
        self.assertEqual(cmd, "ssh:-t -- book m list")

    def test_k_list_edit_delete(self):
        cfg = Path(self.env["BASED_CONFIG"])
        cfg.mkdir(parents=True)
        kb = cfg / "keybinds.tsv"
        kb.write_text("zsh\tf\tfd\nzsh\ts\trg\nnvim\t<Space>ff\tfiles\n")
        zsh_only = self.run_cmd([str(ROOT / "bin/k"), "list", "zsh"]).stdout.splitlines()
        self.assertEqual(len(zsh_only), 2)
        self.run_cmd([str(ROOT / "bin/k"), "delete"], stdin="zsh\tf\tfd\n")
        remaining = self.run_cmd([str(ROOT / "bin/k"), "list"]).stdout.splitlines()
        self.assertEqual(remaining, ["zsh\ts\trg", "nvim\t<Space>ff\tfiles"])
        self.env["EDITOR"] = "printf"
        edited = self.run_cmd([str(ROOT / "bin/k"), "edit", "zsh"]).stdout
        self.assertIn("zshrc", edited)


if __name__ == "__main__":
    unittest.main()
