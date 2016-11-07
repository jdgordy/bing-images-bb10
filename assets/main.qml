import bb.cascades 1.0
import bb.cascades.pickers 1.0
import bb.data 1.0
import bb.platform 1.0
import bb.system 1.0
import my.library 1.0

// Use a NavigationPane to hold contents
NavigationPane {
    
    // Set properties
    id: mainNavigationPane
    peekEnabled: false
    
    // Handler for pop transition
    onPopTransitionEnded: {
        
        // Enable the application menu
        Application.menuEnabled = true
        
        // Delete the viewer page
        page.destroy();
    }
    
    // Create application menu    
    Menu.definition: MenuDefinition {
        
        // Create help action
        helpAction: HelpActionItem {
            
            // Add handler to display help page
            onTriggered: {
                
                // Disable the application menu
                Application.menuEnabled = false;
                
                // Create and display help page
                var helpPage = helpPageDefinition.createObject();
                mainNavigationPane.push(helpPage);
            }
        }
        
        // Create settings action
        settingsAction: SettingsActionItem {
            
            // Add handler to display settings page
            onTriggered: {
                
                // Disable the application menu
                Application.menuEnabled = false
                
                // Create and display settings page
                var settingsPage = settingsPageDefinition.createObject();
                mainNavigationPane.push(settingsPage);
            }
        }
        
        // Create remaining actions
        actions: [
            
            ActionItem {
                
                // Set properties
                imageSource: "asset:///images/ic_info.png"
                title: "Info"
                
                // Add handler to display settings page
                onTriggered: {
                    
                    // Disable the application menu
                    Application.menuEnabled = false
                    
                    // Create and display info page
                    var infoPage = infoPageDefinition.createObject();
                    mainNavigationPane.push(infoPage);
                }
            }
        ]
    }

    // Main application page
    Page {
        
        // Set properties
        id: mainPage
        
        // Define properties
        property variant currentImageUrl;
        property int currentIndex;
        property variant currentDataItem;
        property variant currentMarket;
        property variant currentOrientation;
        
        // Helper function to update XML list
        function updateImageList() {
            
            // Enable activity indicator
            activityBar.text = "Loading image list...";
            activityBar.visible = true;
            activityBar.running = true;
            
            // Reset index and data item
            mainPage.currentImageUrl = null;
            mainPage.currentIndex = 0;
            mainPage.currentDataItem = null;
            
            // Read market and orientation from settings
            mainPage.currentMarket = mainApp.getParameter("Market", "en-US");
            var orientation = mainApp.getParameter("Orientation", "768_1280");
            var dimensions = orientation.split("_");
            var width = dimensions[0];
            var height = dimensions[1];
            mainPage.currentOrientation = width + "x" + height;
            
            // Load XML image data from Bing
            xmlDataSource.source = "http://www.bing.com/HPImageArchive.aspx?format=xml&idx=0&n=10&mkt=" + mainPage.currentMarket;
            xmlDataSource.load();
        }
        
        // Helper function to update image URL
        function updateImageData() {
            
            // Retrieve the data item
            var indexPath = new Array();
            indexPath[0] = mainPage.currentIndex;
            mainPage.currentDataItem = xmlDataModel.data(indexPath);
            
            // Initialize root URL and static attributes
            var rootUrl = "http://www.bing.com";
            var extension = ".jpg";
            
            // Construct and set image URL
            var result = rootUrl;
            result = result + currentDataItem.urlBase;
            result = result + "_" + mainPage.currentOrientation + extension;
            mainPage.currentImageUrl = result;
            
            // Update the share action item
            shareActionItem.query.uri = mainPage.currentImageUrl;
            
            // Update the description box
            descriptionBox.text = mainPage.currentDataItem.copyright;
        }
        
        // Helper function to update image
        function updateImage() {
            
            // Enable activity indicator
            activityBar.text = "Downloading image...";
            activityBar.visible = true;
            activityBar.running = true;
            
            // Set the image source URL and begin downloading
            httpDataSource.source = mainPage.currentImageUrl;
            httpDataSource.load();
        }
        
        // Handler for creation
        onCreationCompleted: {
            
            // Reset index and data item
            currentImageUrl = null;
            currentIndex = 0;
            currentDataItem = null;
            
            // Read market and orientation from settings
            currentMarket = mainApp.getParameter("Market", "en-US");
            var orientation = mainApp.getParameter("Orientation", "768_1280");
            var dimensions = orientation.split("_");
            var width = dimensions[0];
            var height = dimensions[1];
            currentOrientation = width + "x" + height;
            
            // Check if we should refresh on startup
            if( mainApp.getParameter("EnableStartupRefresh", "true") == "true" ) {
                
                // Update the image list
                mainPage.updateImageList();
            }
            
            // Log debug info
            console.log("Current market initialized to " + currentMarket);
            console.log("Current orientation initialized to " + currentOrientation);
        }
        
        // Create container to hold stuff 
        Container {
            
            // Arrange children using docking
            layout: DockLayout {
            }
            
            // Use a scroll view to hold image
            ScrollView {
                
                // Set properties
                id: scrollView
                scrollRole: ScrollRole.Main
                
                // Set scrolling properties
                scrollViewProperties {
                    
                    scrollMode: ScrollMode.Both
                    initialScalingMethod: ScalingMethod.AspectFit
                    minContentScale: 1.0
                    maxContentScale: 8.0
                    pinchToZoomEnabled: true
                    overScrollEffectMode: OverScrollEffectMode.Default
                }
                
                // Fill horizontally and vertically
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                // Create the image view
                ImageView {
                   
                   // Set properties
                   id: imageView
                   scalingMethod: ScalingMethod.AspectFit
                   loadEffect: ImageViewLoadEffect.Subtle
                   
                   // Fill horizontally and vertically
                   horizontalAlignment: HorizontalAlignment.Fill
                   verticalAlignment: VerticalAlignment.Fill
                }
            }
            
            // Create image description box
            DescriptionBox {
                
                // Set properties
                id: descriptionBox
                text: mainPage.currentDataItem.copyright
                visible: false
                
                // Fill horizontally and align at bottom
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Bottom
            }
            
            // Create activity indicator
            ActivityBar {
                
                // Set properties
                id: activityBar
                visible: false
                running: false
                
                // Fill horizontally and align at top
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Top
            }
        }
        
        actions: [
            
            // Previous image action
            ActionItem {
                
                // Set properties
                title: "Previous"
                imageSource: "asset:///images/ic_previous.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                enabled: (mainPage.currentDataItem != null && mainPage.currentIndex < 6)

                // Handler for trigger
                onTriggered: {
                    
                    // Update the current index
                    mainPage.currentIndex = Math.min(mainPage.currentIndex + 1, 6);
                    
                    // Update the image data
                    mainPage.updateImageData();
                    
                    // Update the image
                    mainPage.updateImage();
                    
                    // Log debug info
                    console.log("Current index set to " + mainPage.currentIndex);
                }
            },
            
            // Next image action
            ActionItem {
                
                // Set properties
                title: "Next"
                imageSource: "asset:///images/ic_next.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                enabled: (mainPage.currentDataItem != null && mainPage.currentIndex > 0)
                
                // Handler for trigger
                onTriggered: {
                    
                    // Update the current index
                    mainPage.currentIndex = Math.max(mainPage.currentIndex - 1, 0);
                    
                    // Update the image data
                    mainPage.updateImageData();
                    
                    // Update the image
                    mainPage.updateImage();
                    
                    // Log debug info
                    console.log("Current index set to " + mainPage.currentIndex);
                }
            },
            
            // Toggle notes action
            ActionItem {
                
                // Set properties
                id: notesAction
                title: "Show Notes"
                imageSource: "asset:///images/ic_notes.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                enabled: mainPage.currentDataItem != null
                
                // Handler for trigger
                onTriggered: {
                    
                    // Toggle description box
                    if( descriptionBox.visible ) {
                        notesAction.title = "Show Notes";
                        descriptionBox.visible = false;
                    }
                    else {
                        notesAction.title = "Hide Notes";
                        descriptionBox.visible = true;
                    }
                    
                    // Log debug info
                    console.log("Notes toggled");
                }
            },
            
            // Copy image link action
            ActionItem {
                
                // Set properties
                title: "Copy Image Link"
                imageSource: "asset:///images/ic_copy_link_image.png"
                ActionBar.placement: ActionBarPlacement.InOverflow
                enabled: mainPage.currentDataItem != null
                
                // Handler for trigger
                onTriggered: {
                    
                    // Call application helper function
                    mainApp.copyUrl(mainPage.currentImageUrl, "text/plain");
                    
                    // Log debug info
                    console.log("Image link copied to clipboard: ");
                }
            },
            
            // Save image action
            ActionItem {
                
                // Set properties
                title: "Save Image"
                imageSource: "asset:///images/ic_save_image.png"
                ActionBar.placement: ActionBarPlacement.InOverflow
                enabled: mainPage.currentDataItem != null
                
                // Handler for trigger
                onTriggered: {
                    
                    // Show the file save page
                    filePicker.defaultSaveFileNames = "BingImage_" + mainPage.currentDataItem.startdate + ".jpg";
                    filePicker.open();
                }
            },
            
            // Share action
            InvokeActionItem {
                
                // Set properties
                id: shareActionItem
                title: "Share"
                imageSource: "asset:///images/ic_share.png"
                ActionBar.placement: ActionBarPlacement.InOverflow
                enabled: mainPage.currentDataItem != null
                
                query {
                    
                    // Set properties
                    invokeActionId: "bb.action.SHARE"
                    uri: "http://www.bing.com"
                    mimeType: "image/*"
                    
                    // Handler for query change
                    onQueryChanged: {
                        
                        // Update the query
                        shareActionItem.query.updateQuery();
                    }
                }
            },
            
            // Set wallpaper action
            ActionItem {
                
                // Set properties
                title: "Set As Wallpaper"
                imageSource: "asset:///images/ic_set_as_wallpaper.png"
                ActionBar.placement: ActionBarPlacement.Signature
                enabled: mainPage.currentDataItem != null
                
                // Handler for trigger
                onTriggered: {
                    
                    // Enable activity indicator
                    activityBar.text = "Setting wallpaper...";
                    activityBar.visible = true;
                    activityBar.running = true;
                    
                    // Set the file target URL and begin downloading
                    httpDownloadSource.source = mainPage.currentImageUrl;
                    httpDownloadSource.target = "file:///accounts/1000/shared/photos/bing_wallpaper.jpg";
                    httpDownloadSource.setWallpaper = true;
                    httpDownloadSource.load();
                    
                    // Log debug info
                    console.log("Setting wallpaper " + httpDownloadSource.source);
                }
            },
            
            // Refresh action
            ActionItem {
                
                // Set properties
                title: "Refresh"
                imageSource: "asset:///images/ic_reload.png"
                ActionBar.placement: ActionBarPlacement.InOverflow
                
                // Handler for trigger
                onTriggered: {
                    
                    // Update the image list
                    mainPage.updateImageList();
                    
                    // Log debug info
                    console.log("Loading XML image list from " + xmlDataSource.source);
                }
            }
        ]
    
        // Additional objects
        attachedObjects: [
            
            // System toast
            SystemToast {
                
                // Set properties
                id: systemToast
                body: ""
            },
            
            // Data model
            GroupDataModel {
                
                // Set properties
                id: xmlDataModel
                sortingKeys: ["startdate"]
                sortedAscending: false
                grouping: ItemGrouping.None
            },
            
            // XML data source for Bing images 
            DataSource {
                
                // Set properties
                id: xmlDataSource
                source: ""
                query: "/images/image"
                type: DataSourceType.Xml
                
                // Handler for dataLoaded signal
                onDataLoaded: {
                    
                    // Set model data, checking if we're returned a single element or list
                    xmlDataModel.clear();
                    if (data[0] == undefined) {
                        // Add single element
                        xmlDataModel.insert(data)
                    } else {
                        // Add list of elements
                        xmlDataModel.insertList(data)
                    }
                    
                    // Update the image data
                    mainPage.updateImageData();
                    
                    // Update the image
                    mainPage.updateImage();
                    
                    // Log debug info
                    console.log("Loaded XML image list data");
                }
                
                // Handler for error signal
                onError: {
                    
                    // Disable activity indicator
                    activityBar.visible = false;
                    activityBar.running = false;
                    
                    // Display error toast
                    systemToast.body = "Unable to load image list - error: " + errorType + ", message: " + errorMessage;
                    systemToast.show();
                    
                    // Log error
                    console.log("Unable to load image list - error: " + errorType + ", message: " + errorMessage);
                }
            },
            
            // HTTP data source
            HttpDataSource {
                
                // Set properties
                id: httpDataSource
                source: null
                target: null
                
                // Handler for image loaded signal
                onImageLoaded: {
                    
                    // Disable activity indicator
                    activityBar.visible = false;
                    activityBar.running = false;
                    
                    // Set image view data
                    scrollView.resetViewableArea();
                    imageView.image = image;
                    
                    // Log debug info
                    console.log("Loaded image from URL: " + source + ", MIME type: " + mimeType);
                }
                
                // Handler for error signal
                onError: {
                    
                    // Disable activity indicator
                    activityBar.visible = false;
                    activityBar.running = false;
                    
                    // Display error toast
                    systemToast.body = "Unable to load image - error: " + errorType + ", message: " + errorMessage;
                    systemToast.show();
                    
                    // Log error
                    console.log("Unable to load image - error: " + errorType + ", message: " + errorMessage);
                }
            },
            
            // HTTP data source for downloading
            HttpDataSource {
                
                // Define properties
                property bool setWallpaper;
                
                // Set properties
                id: httpDownloadSource
                source: null
                target: null
                
                // Handler for target updated signal
                onTargetUpdated: {
                    
                    // Disable activity indicator
                    activityBar.visible = false;
                    activityBar.running = false;
                    
                    // Check if we're setting the wallpaper
                    if( setWallpaper ) {
                        
                        // Set the wallpaper
                        mainApp.setWallpaper(target);
                        
                        // Log debug info
                        console.log("Wallpaper changed");
                    }
                    else {
                        
                        // Display toast
                        systemToast.body = "Image saved to: " + target;
                        systemToast.show();
                        
                        // Log debug info
                        console.log("Image saved to: " + target);
                    }
                }
                
                // Handler for error signal
                onError: {
                    
                    // Disable activity indicator
                    activityBar.visible = false;
                    activityBar.running = false;
                    
                    // Display error toast
                    systemToast.body = "Unable to save image - error: " + errorType + ", message: " + errorMessage;
                    systemToast.show();
                    
                    // Log error
                    console.log("Unable to save image - error: " + errorType + ", message: " + errorMessage);
                }
            },
            
            // File picker definition
            FilePicker {
                
                // Set properties
                id: filePicker
                title : "Save Image"
                type : FileType.Picture
                mode: FilePickerMode.Saver
                directories: ["/accounts/1000/shared/misc"]
                
                // Handler for file selected signal
                onFileSelected : {
                    
                    // Enable activity indicator
                    activityBar.text = "Saving image...";
                    activityBar.visible = true;
                    activityBar.running = true;
                    
                    // Set the file target URL and begin downloading
                    httpDownloadSource.source = mainPage.currentImageUrl;
                    httpDownloadSource.target = selectedFiles[0];
                    httpDownloadSource.setWallpaper = false;
                    httpDownloadSource.load();
                    
                    // Log debug info
                    console.log("Selected save location: " + selectedFiles);
                }
                
                // Handler for cancelled signal
                onCanceled: {
                    
                    // Clear the image source and target URLs
                    httpDownloadSource.source = null;
                    httpDownloadSource.target = null;
                }
            },
            
            HomeScreen {
                
                // Set properties
                id: homeScreen
            }
        ]
    }
    
    attachedObjects: [
        
        // Help page definition            
        ComponentDefinition {
            
            // Set properties
            id: helpPageDefinition
            source: "HelpPage.qml"
        },
    
        // Settings page definition
        ComponentDefinition {
            
            // Set properties
            id: settingsPageDefinition
            source: "SettingsPage.qml"
        },
        
        // Info page definition
        ComponentDefinition {
            
            // Set properties
            id: infoPageDefinition
            source: "InfoPage.qml"
        }
    ]
}