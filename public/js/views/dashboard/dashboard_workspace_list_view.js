(function($, ns) {
    ns.DashboardWorkspaceList = chorus.views.Base.extend({
        className : "dashboard_workspace_list",
        tagName : "ul",
        additionalClass : "list",
        useLoadingSection : true,

        collectionModelContext: function(model) {
            var comments = model.comments().models;
            return {
                imageUrl : model.defaultIconUrl(),
                showUrl : model.showUrl(),
                numComments : comments.length,
                latestComment : comments[0] && {
                    timestamp: comments[0].get("timestamp"),
                    author : comments[0].author().displayName()
                }
            }
        },

        postRender: function() {
            this.collection.each(function(workspace) {
                var li = this.$("li[data-id=" + workspace.get("id") + "]");
                var commentList = new chorus.views.CommentList({
                    collection: workspace.comments(),
                    initialLimit: 5,
                    displayStyle : 'without_workspace'
                });
                var el = $(commentList.render().el);
                el.find("ul").addClass("tooltip");

                li.find(".comment .count").qtip({
                    content: el.html(),
                    show: 'mouseover',
                    hide: {
                        delay: 500,
                        fixed: true,
                        when: { event: 'mouseout' }
                    },
                    style: {
                        width: 300
                    },
                    position : {
                        corner : {
                            target: "leftMiddle",
                            tooltip: "rightMiddle"
                        },
                        adjust : {
                            screen : true,
                            scroll : false,
                            mouse: false
                        }
                    }
                });
            }, this);
        }
    });
})(jQuery, chorus.views);
