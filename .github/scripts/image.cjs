exports.source = async (github, context) => {
  const { data: prs } = await github.rest.repos.listPullRequestsAssociatedWithCommit({
    ...context.repo, commit_sha: context.sha,
  });
  const merged = prs.filter(pr => pr.merged_at && pr.merge_commit_sha === context.sha && pr.base.ref === 'main');
  if (merged.length !== 1 || !/^[a-f0-9]{40}$/.test(merged[0].head.sha)) {
    throw new Error('Expected one merged PR for this main commit; refusing to rebuild or select an unrelated image.');
  }
  const head = merged[0].head.sha;
  const { data } = await github.rest.actions.listWorkflowRuns({
    ...context.repo, workflow_id: 'ci.yml', event: 'pull_request', head_sha: head, status: 'success', per_page: 100,
  });
  const runs = data.workflow_runs
    .filter(run => run.head_sha === head && run.event === 'pull_request' && run.conclusion === 'success')
    .sort((a, b) => b.id - a.id);
  if (!runs.length || !Number.isSafeInteger(runs[0].id)) {
    throw new Error('No successful PR build exists for the merged head.');
  }
  return runs[0].id;
};

exports.verify = (metadata, tree) => {
  if (metadata.tree !== tree) {
    throw new Error('Merged tree differs from the tested PR image; refusing to publish a stale artifact.');
  }
  if (typeof metadata.image !== 'string' || !/^sha256:[a-f0-9]{64}$/.test(metadata.image)) {
    throw new Error('Invalid artifact image identity.');
  }
  return metadata.image;
};
