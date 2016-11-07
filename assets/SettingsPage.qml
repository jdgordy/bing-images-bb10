import bb.cascades 1.0
import bb.data 1.0

// Create the main page
Page {

    // Create title bar
    titleBar: TitleBar {

        // Set properties
        title: "Settings"
    }

    // Handler for creation completed
    onCreationCompleted: {

        // Load the region / locale table
        regionDataSource.load();
        
        // Load the application parameters
        startupRefreshToggle.checked = mainApp.getParameter("EnableStartupRefresh", "true");
        regionOption.setSelectedIndex(regionOption.findIndex(mainApp.getParameter("Market", "en-US")));
        orientationOption.setSelectedIndex(orientationOption.findIndex(mainApp.getParameter("Orientation", "768,1280")));
    }
    
    // Create a container to hold all controls
    Container {

        // Arrange children top-to-bottom
        layout: StackLayout {
            orientation: LayoutOrientation.TopToBottom
        }

        // Set some padding for child controls
        topPadding: 10
        bottomPadding: 10
        leftPadding: 10
        rightPadding: 10

        // Refresh on startup toggle
        ToggleField {
            
            // Set properties
            id: startupRefreshToggle
            text: "Refresh image list at startup"
            
            // Fill horizontally
            horizontalAlignment: HorizontalAlignment.Fill
            
            // Handler for checked
            onCheckedChanged: {
                
                // Set the application parameter
                mainApp.setParameter("EnableStartupRefresh", checked);
            }
        }
        
        // Market / region drop-down
        DropDown {
            
            // Set properties
            id: regionOption
            title: "Region / Language"
            
            // Fill horizontally
            horizontalAlignment: HorizontalAlignment.Fill
            
            // Handler for option change
            onSelectedValueChanged: {
                
                // Set the application parameter
                mainApp.setParameter("Market", selectedValue.toString());
            }
            
            // Map from option value to selected index
            function findIndex(value) {
                for (var i = 0; i < count(); i ++) {
                    if (at(i).value == value) return i;
                }
                return i - 1; // default
            }
        }
        
        // Orientation drop-down
        DropDown {
            
            // Set properties
            id: orientationOption
            title: "Orientation"
            
            // Fill horizontally
            horizontalAlignment: HorizontalAlignment.Fill
            
            Option {
                text: "768x1280 (Portrait)"
                value: "768_1280"
            }
            
            Option {
                text: "1280x768 (Landscape)"
                value: "1280_768"
            }
            
            Option {
                text: "720x1280 (Portrait)"
                value: "720_1280"
            }
            
            Option {
                text: "1280x720 (Landscape)"
                value: "1280_720"
            }
            
            Option {
                text: "1080x1920 (Portrait)"
                value: "1080_1920"
            }
            
            Option {
                text: "1920x1080 (Landscape)"
                value: "1920_1080"
            }
            
            Option {
                text: "768x1024 (Portrait)"
                value: "768_1024"
            }
            
            Option {
                text: "1024x768 (Landscape)"
                value: "1024_768"
            }
            
            Option {
                text: "480x800 (Portrait)"
                value: "480_800"
            }
            
            Option {
                text: "800x480 (Landscape)"
                value: "800_480"
            }
            
            // Handler for option change
            onSelectedValueChanged: {
                
                // Set the application parameter
                mainApp.setParameter("Orientation", selectedValue.toString());
            }
            
            // Map from option value to selected index
            function findIndex(value) {
                for (var i = 0; i < count(); i ++) {
                    if (at(i).value == value) return i;
                }
                return i - 1; // default
            }
        }
    }
    
    attachedObjects: [
        
        // Option definition
        ComponentDefinition {
            
            // Set properties
            id: optionDefinition
            Option {
            }
        },
        
        // JSON data source for regions / locales 
        DataSource {
            
            // Set properties
            id: regionDataSource
            source: "asset:///regions.json"
            type: DataSourceType.Json
            
            // Handler for data loaded signal
            onDataLoaded: {
                
                // Remove any existing options
                regionOption.removeAll();
                
                // Check if we're returned an object or list
                if( data[0] != undefined ) {
                    // Add list of region / locale options
                    for( var i = 0; i < data.length; i++ ) {
                        var option = optionDefinition.createObject();
                        option.text = data[i].region;
                        option.value = data[i].locale;
                        regionOption.add(option)
                    }
                }
                else {
                    // Add single region / locale option
                    for( var i = 0; i < data.length; i++ ) {
                        var option = optionDefinition.createObject();
                        option.text = data.region;
                        option.value = data.locale;
                        regionOption.add(option)
                    }
                }
                
                // Log debug info
                console.log("Loaded region / locale list");
            }
            
            // Handler for error signal
            onError: {
                
                // Display error toast
                systemToast.body = "Unable to load region / locale list - error: " + errorType + ", message: " + errorMessage;
                systemToast.show();
                
                // Log error
                console.log("Unable to load region / locale list - error: " + errorType + ", message: " + errorMessage);
            }
        }
    ]
}
