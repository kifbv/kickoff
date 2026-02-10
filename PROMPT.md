I want to build a framework that will be used to interview a user and guide them in creating a greenfield project's PRD. For instance, the user might want to create from scratch a webapp to manage the movies they have watched and those they want to watch. Once that PRD ready, it would be used to discuss the project's ideas and identify jobs/features to be done (and create those feature's PRDs). Then the 3rd phase would be to split those features into atomic tasks and an implementation plan.

Part of these phases is done with a Ralph loop, implemented differently in directories you have access to:
- ~/Projects/anthropics/claude-quickstarts/autonomous-coding/
- ~/Projects/snarktank/ralph

The Ralph loop principle (context allocation), strategies (one atomic task per agent session) and tactics (deterministic bash script) is detailed in another directory (inspired by the findings of Geoffrey Huntley):
- ~/Projects/ClaytonFarr/ralph-playbook/

Another important document in understanding why and how Ralph loops can be use to manage long running agents is:
- https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents

I want you to ask different sub agents to read these documents and search the web to validate my understanding of the Ralph loop principle, strategies and tactic.
Once this is done and you have a perfect understanding of the problem, we will have a brainstorming with me so that we can:
- take the best of anthropics and snartank implementation of the Ralph loop to scafold our own version in this repo
- add whatever is necessarry (skills, agents, scripts...) to this repo to make it easier to start a project from scratch (instead of running the Ralph loop in an existing project).

