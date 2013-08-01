describe("chorus.views.JobContentDetails", function () {

    beforeEach(function () {
        this.job = backboneFixtures.job();
        this.view = new chorus.views.JobContentDetails({model: this.job});
        this.modalSpy = stubModals();
        this.qtipElement = stubQtip();
        this.view.render();
    });

    describe("clicking the 'Add Task' button", function () {
        beforeEach(function () {
            this.view.$("button.create_task").click();
        });

        it("enables the 'Import Source Data' link", function () {
            expect(this.qtipElement.find(".import_source_data").text()).toMatchTranslation("job_task.action.import_source_data");
        });

        it("enables the 'Run Workflow' link", function() {
            expect(this.qtipElement.find(".run_work_flow").text()).toMatchTranslation("job_task.action.run_work_flow");
        });

        context("clicking on 'Run Work Flow'", function () {
            it("launches the WorkFlowPicker dialog", function() {
                expect(this.modalSpy).not.toHaveModal(chorus.dialogs.CreateWorkFlowTask);
                this.qtipElement.find('.run_work_flow').click();
                expect(this.modalSpy).toHaveModal(chorus.dialogs.CreateWorkFlowTask);
            });

            it("launches the picker dialog with only work flows", function() {
                expect(this.modalSpy.modals[0].options.fileType).toBe('alpine');
            });

        });

        context("clicking on 'Add Import Source Data'", function () {
            it("launches the CreateImportSourceDataTask dialog", function () {
                expect(this.modalSpy).not.toHaveModal(chorus.dialogs.CreateImportSourceDataTask);
                this.qtipElement.find('.import_source_data').click();
                expect(this.modalSpy).toHaveModal(chorus.dialogs.CreateImportSourceDataTask);
            });
        });
    });

    describe("clicking the 'Enable' button", function () {
        it("posts to the API with the right parameters", function () {
            this.view.$('button.toggle_enabled').click();

            var params = this.server.lastUpdate().params();
            expect(params['job[enabled]']).toBe("true");
        });

        it("shows the enabling/disabling text", function () {
            this.view.$('button.toggle_enabled').click();
            expect(this.view.$('button.toggle_enabled')).toContainTranslation("job.actions.saving");
            expect(this.view.$('button.toggle_enabled')).toBeDisabled();
        });

        context("when the save Succeeds", function () {
            it("toggles the button text", function () {
                expect(this.view.$('button.toggle_enabled')).toContainTranslation('job.actions.enable');
                this.view.$('button.toggle_enabled').click();
                this.server.completeUpdateFor(this.view.model);
                expect(this.view.$('button.toggle_enabled')).toContainTranslation('job.actions.disable');
            });

            it("toggles the action bar styling", function () {
                expect(this.view.$('.action_bar')).toHaveClass('action_bar_limited');
                this.view.$('button.toggle_enabled').click();
                this.server.completeUpdateFor(this.view.model);
                expect(this.view.$('.action_bar')).toHaveClass('action_bar_highlighted');
            });

        });
    });

    itBehavesLike.aDialogLauncher('.edit_schedule', chorus.dialogs.EditJob);
});
