describe("chorus.dialogs.EditTags", function() {
    beforeEach(function() {
        this.model1 = rspecFixtures.workfile.sql({tags: [
            {name: "tag1"},
            {name: "tag2"}
        ]});
        this.model2 = rspecFixtures.workfile.sql({tags: [
            {name: "tag1"},
            {name: "tag3"}
        ]});
        this.collection = rspecFixtures.workfileSet();
        this.collection.reset([
            this.model1.attributes, this.model2.attributes
        ]);
        this.dialog = new chorus.dialogs.EditTags({collection: this.collection});
        spyOn(this.dialog, "closeModal");
        this.dialog.render();
    });

    it("has the right title", function() {
        expect(this.dialog.title).toMatchTranslation("edit_tags.title");
    });

    it("displays all the relevant tags", function() {
        expect(this.dialog.$(".text-tags")).toContainText("tag1");
        expect(this.dialog.$(".text-tags")).toContainText("tag2");
        expect(this.dialog.$(".text-tags")).toContainText("tag3");
    });

    describe("clicking the close button", function(){
        beforeEach(function(){
           this.dialog.$(".cancel").click();
        });

        it("closes the dialog", function(){
            expect(this.dialog.closeModal).toHaveBeenCalled();
        });
    });

    describe("after the dialog is revealed by facebox", function() {
        it("waits for facebox to finalize position before focusing so the page doesn't scroll weirdly", function() {
            clock.install();
            this.dialog.launchModal();

            spyOn(this.dialog.tagsInput, "focusInput");
            expect(this.dialog.tagsInput.focusInput).not.toHaveBeenCalled();
            clock.tick(1);
            expect(this.dialog.tagsInput.focusInput).toHaveBeenCalled();

            this.dialog.closeModal();
            $(document).trigger("close.facebox");
        });
    });

    describe("editing tags", function() {
        beforeEach(function() {
            this.model1 = rspecFixtures.workfile.sql({
                tags: [
                    {name: "tag1"},
                    {name: "tag2"}
                ]
            });
            this.model2 = rspecFixtures.workfile.sql({
                tags: [
                    {name: "tag1"},
                    {name: "tag3"}
                ]
            });
            this.collection = rspecFixtures.workfileSet();
            this.collection.reset([this.model1, this.model2]);
            this.dialog = new chorus.dialogs.EditTags({collection: this.collection});
            spyOn(this.collection, "updateTags").andCallThrough();
            this.dialog.render();
        });

        it("displays all the relevant tags", function() {
            expect(this.dialog.$(".text-tags")).toContainText("tag1");
            expect(this.dialog.$(".text-tags")).toContainText("tag2");
            expect(this.dialog.$(".text-tags")).toContainText("tag3");
            expect(this.dialog.$(".text-button").length).toBe(3);
        });

        describe('when a tag is added', function() {
            it('adds the tag to all the models', function() {
                enterTag(this.dialog, "foo");
                this.collection.each(function(model) {
                    expect(model.tags().pluck('name')).toContain('foo');
                });
            });

            it('saves the tags', function() {
                enterTag(this.dialog, "foo");
                expect(this.collection.updateTags).toHaveBeenCalled();
                expect(this.collection.updateTags.mostRecentCall.args[0].add.name()).toBe("foo");
            });

            it('triggers change:tags on each model in the collection', function() {
                var savedModel = this.collection.last();
                spyOnEvent(savedModel, "change:tags");
                enterTag(this.dialog, "foo");
                this.server.lastCreate().succeed();
                expect("change:tags").toHaveBeenTriggeredOn(savedModel);
            });

            context('when the tag is already on some of the models', function() {
               beforeEach(function(){
                   enterTag(this.dialog, "foo");
               });

                it('saves the tags', function() {
                    expect(this.collection.updateTags).toHaveBeenCalled();
                    expect(this.collection.updateTags.mostRecentCall.args[0].add.name()).toBe("foo");
                });

                it('adds the tag to all the models', function(){
                    this.collection.each(function(model) {
                        expect(model.tags().pluck('name')).toContain('foo');
                    });
                });

                it('puts the new tag at the end', function(){
                    expect(this.dialog.tags().last().get('name')).toEqual('foo');
                });
            });

            context('when the save fails', function(){
                beforeEach(function() {
                    enterTag(this.dialog, "foo");
                    spyOn(this.dialog, "showErrors");
                    this.server.lastCreate().failForbidden({message: "Forbidden"});
                });

                it("shows an error message", function() {
                    expect(this.dialog.showErrors).toHaveBeenCalledWith(jasmine.objectContaining({serverErrors: {message: 'Forbidden'}}));
                });

                it("hides the tags input so the user cannot enter more tags without closing the dialog", function() {
                    expect(this.dialog.$('.tags_input')).toHaveClass('hidden');
                });
            });
        });

        describe("when a tag is removed using the x button", function() {
            beforeEach(function() {
                this.dialog.$(".text-remove:eq(0)").click();
            });

            it('removes a tag from all the models', function() {
                this.collection.each(function(model) {
                    expect(model.tags().pluck('name')).not.toContain('tag1');
                });
            });

            it('saves the tags', function(){
                expect(this.collection.updateTags).toHaveBeenCalled();
                expect(this.collection.updateTags.mostRecentCall.args[0].remove.name()).toBe("tag1");
            });
        });
    });
});