Please conduct a thorough code review of this pull request. The first thing you must do it checkout the code.
Focus on:
- Code quality and best practices
- In spec files:
  - Flag if there is use of mock components
- Performance implications
- Potential bugs or logic errors
- Security vulnerabilities
- Check for mispellings ( use Australian English )
- Ensure edits to en_AU.json are in alphabetical order
- Test coverage gaps
- Check the original components themselves to make sure there's no regressions or faults

Scripts you can use to assist:
 - mm_debug which will `cd` into the workspace root of your code review

Notes:
 - Do not run vitest for the code-review - it is too time consuming
 - Do not run typescript typechecks for the code-review - it is too time consuming
