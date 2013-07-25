chorus.dialogs.EditJob = chorus.dialogs.Base.include(chorus.Mixins.DialogFormHelpers).extend({
    constructorName: 'EditJob',
    templateName: 'create_job_dialog',
    title: t('job.dialog.title.edit'),
    message: 'job.dialog.toast.edit'
});