describe("chorus.dialogs.CreateWorkFlowTask", function() {
    describe('#render', function() {
        beforeEach(function() {
            var workspace = {workspace: {id: 1}};
            this.workFlows = [
                backboneFixtures.workfile.alpine(workspace),
                backboneFixtures.workfile.alpine(workspace)
            ];

            this.workFlowSet = new chorus.collections.WorkfileSet(this.workFlows, {fileType: 'alpine'});
            this.dialog = new chorus.dialogs.CreateWorkFlowTask({collection: this.workFlowSet});
            this.dialog.render();
        });

        it("shows the correct title", function() {
            expect(this.dialog.$("h1").text()).toMatchTranslation("job_task.work_flow.title");
        });

        it("only fetches work flows", function() {
            var lastFetch = this.server.lastFetchFor(this.workFlowSet);
            expect(lastFetch.url).toEqual('/workspaces/' + this.workFlowSet.models[0].workspace().id + '/workfiles?file_type=alpine');
        });

        context("when the collection fetch completes", function() {
            beforeEach(function() {
                this.server.completeFetchAllFor(this.workFlowSet, this.workFlows);
            });

            it("shows the correct search placeholder", function() {
                expect(this.dialog.$("input.chorus_search").attr("placeholder")).toMatchTranslation("job_task.work_flow.search_placeholder");
            });
        });
    });
});
