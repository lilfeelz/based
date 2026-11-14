const test = require('node:test');
const assert = require('node:assert/strict');
const { source, verify } = require('./image.cjs');

const sha = 'a'.repeat(40);
const head = 'b'.repeat(40);
const tree = 'c'.repeat(40);
const image = `sha256:${'d'.repeat(64)}`;
const context = { repo: { owner: 'lilfeelz', repo: 'based' }, sha };
const pr = { merged_at: '2026-11-14', merge_commit_sha: sha, base: { ref: 'main' }, head: { sha: head } };

function client(prs, runs) {
  return { rest: {
    repos: { listPullRequestsAssociatedWithCommit: async () => ({ data: prs }) },
    actions: { listWorkflowRuns: async (args) => {
      assert.equal(args.head_sha, head);
      assert.equal(args.event, 'pull_request');
      assert.equal(args.workflow_id, 'ci.yml');
      assert.equal(args.status, 'success');
      return { data: { workflow_runs: runs } };
    } },
  } };
}

test('select the latest successful PR run for the merged head, not an unrelated run', async () => {
  const github = client([pr], [
    { id: 10, head_sha: head, event: 'pull_request', conclusion: 'success' },
    { id: 11, head_sha: head, event: 'pull_request', conclusion: 'success' },
    { id: 12, head_sha: head, event: 'pull_request', conclusion: 'failure' },
    { id: 13, head_sha: sha, event: 'pull_request', conclusion: 'success' },
    { id: 14, head_sha: head, event: 'push', conclusion: 'success' },
  ]);
  assert.equal(await source(github, context), 11);
});

test('a direct push cannot publish a random recent artifact', async () => {
  await assert.rejects(source(client([], []), context), /merged PR/);
});

test('a closed but unmerged PR cannot publish', async () => {
  await assert.rejects(source(client([{ ...pr, merged_at: null }], []), context), /merged PR/);
});

test('a PR for a different merge commit cannot publish', async () => {
  await assert.rejects(source(client([{ ...pr, merge_commit_sha: head }], []), context), /merged PR/);
});

test('no successful source build fails without rebuilding on main', async () => {
  await assert.rejects(source(client([pr], []), context), /successful PR build/);
});

test('matching tree and image identity can be promoted', () => {
  assert.equal(verify({ tree, image }, tree), image);
});

test('an artifact from a stale source tree is rejected', () => {
  assert.throws(() => verify({ tree: head, image }, tree), /tree/);
});

test('an arbitrary image name or malformed digest cannot be promoted', () => {
  for (const value of ['other/image:latest', '--help', 'sha256:short', null]) {
    assert.throws(() => verify({ tree, image: value }, tree), /image/);
  }
});
