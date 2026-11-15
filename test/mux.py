"""Attach from a selection pipe must restore the controlling terminal."""
import os
from pathlib import Path
import pty
import subprocess
import sys
import tempfile

root = Path(sys.argv[1])
with tempfile.TemporaryDirectory() as tmp:
    mock = Path(tmp) / "zmx"
    mock.write_text("#!/bin/sh\n[ -t 0 ] || exit 42\nprintf 'terminal restored'\n")
    mock.chmod(0o755)
    pid, fd = pty.fork()
    if pid == 0:
        env = dict(os.environ, PATH=tmp + os.pathsep + os.environ["PATH"])
        env.pop("ZMX_SESSION", None)
        result = subprocess.run([str(root / "bin/m"), "attach"], input="demo\n", text=True, capture_output=True, env=env)
        os._exit(0 if result.returncode == 0 and result.stdout == "terminal restored" else 1)
    _, status = os.waitpid(pid, 0)
    os.close(fd)
    assert os.waitstatus_to_exitcode(status) == 0, "selection pipe reached zmx instead of the terminal"
