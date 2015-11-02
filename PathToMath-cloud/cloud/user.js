Parse.Cloud.afterSave(Parse.User, function(request) {
    Parse.Cloud.useMasterKey();
    var user = request.object;
    if (user.existed()) {
        response.success();
    } else {
        var GameProgress = Parse.Object.extend("GameProgress");
        var newUserGameProgress = new GameProgress()
        newUserGameProgress.save({
            user: user,
            mode: "Approximate",
            level: 1
        }, { success: function(newUserGameProgress) {
            console.log("Created GameProgress entry for new user.")
        }, error: function(newUserGameProgress, error) {
            console.log("Failed to create GameProgress entry.");
        }});
    }
});
