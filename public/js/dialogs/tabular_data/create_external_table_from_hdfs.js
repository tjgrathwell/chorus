chorus.dialogs.CreateExternalTableFromHdfs = chorus.dialogs.NewTableImportCSV.extend({
    title: t("hdfs.create_external.title"),
    ok: t("hdfs.create_external.ok"),


    setup: function() {
        this._super("setup", arguments);

        this.workspaces = new chorus.collections.WorkspaceSet([], {userId: chorus.session.user().id});
        this.workspaces.fetchAll();
        this.requiredResources.push(this.workspaces);
    },

    postRender : function() {
        this._super("postRender", arguments)

        if(this.workspaces.loaded){
            if(!this.workspaces.length) {
                this.workspaces.serverErrors = [{message: t("hdfs.create_external.no_workspaces")}];
                this.showErrors(this.workspaces);
            }

            chorus.styleSelect(this.$("select"));
        }
    },

    additionalContext: function() {
        var parentCtx = this._super("additionalContext", arguments);
        parentCtx.workspaces = _.pluck(this.workspaces.models, "attributes");
        return parentCtx;
    }
});