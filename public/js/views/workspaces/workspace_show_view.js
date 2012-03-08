chorus.views.WorkspaceShow = chorus.views.Base.extend({
    constructorName: "WorkspaceShowView",
    className: "workspace_show",
    useLoadingSection: true,

    subviews: {
        ".activity_list": "activityList"
    },

    setup:function () {
        this.collection = this.model.activities();
        this.collection.fetch();
        this.requiredResources.add(this.collection);

        this.activityList = new chorus.views.ActivityList({
            collection: this.collection,
            additionalClass: "workspace_detail",
            displayStyle: "without_workspace"
        });
    }
});
