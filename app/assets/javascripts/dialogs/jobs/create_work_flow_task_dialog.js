chorus.dialogs.CreateWorkFlowTask = chorus.dialogs.PickItems.extend({
    constructorName: 'CreateWorkFlowTask',
    title: t('job_task.work_flow.title'),
    searchPlaceholderKey: 'job_task.work_flow.search_placeholder',

    setup: function() {
        this._super("setup");
        this.collection =
        this.collection.fetch();
    }
});