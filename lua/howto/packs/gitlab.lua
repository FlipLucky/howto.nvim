-- gitlab.nvim: review GitLab merge requests. Default global keymaps.
return {
    plugin = "gitlab.nvim",
    nodes = {
        { path = "review", label = "Review (GitLab MR)", order = 12.5, desc = "Merge requests from inside Neovim. In gitlab.nvim's windows, g? shows the keys." },
    },
    entries = {
        { keys = "glc", at = "review", label = "choose an MR to review", desc = "Lists open merge requests; picking one checks out the branch and opens the review." },
        { keys = "glS", at = "review", label = "review the current branch", desc = "Starts the review for the MR of the branch you're on." },
        { keys = "gld", at = "review", label = "discussions", desc = "Toggles the discussion tree: r reply, - resolve, o jump to the code." },
        { keys = "c", at = "review", label = "comment (in the diff)", desc = "In the reviewer diff: c + a motion comments on those lines; s makes a suggestion." },
        { keys = "glp", at = "review", label = "pipeline status", desc = "Shows the MR's pipeline and its jobs." },
        { keys = "glo", at = "review", label = "open in the browser", desc = "Opens the MR on GitLab. glu copies the URL." },
        { keys = "glA", at = "review", label = "approve", desc = "Approves the MR. glR revokes. Careful: glM merges." },
    },
}
