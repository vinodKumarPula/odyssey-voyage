import "util" as util;

fn formatError(response) {
    try {
        print("INSIDE FORMAT ERROR"+ response);
        if response?.body?.errors?.len() > 0 {
            let extentionsAllowList = "code,stacktrace";
            let extentionsAllowList = extentionsAllowList.split(",");
            response.body.errors = response.body.errors.map(|error| {
                if(error?.extensions?.len() > 0) {
                    let filteredExtensions = error.extensions.filter(|key, value| {
                        extentionsAllowList.contains(key)
                    });
                    error.extensions = filteredExtensions;
                }
                error
            });
        }
    } catch (error) {
        throw "Error while formatting error response: " + error;
    }
}
