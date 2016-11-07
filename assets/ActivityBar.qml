import bb.cascades 1.0
import bb.system 1.0

Container {
    
    // Define property aliases
    property alias text: titleField.text
    property alias running: activityField.running 
    
    // Arrange children using docking
    layout: DockLayout {
    }
    
    // Create empty container for translucent background
    Container {

        // Set properties
        background: Color.Black
        opacity: 0.5

        // Fill horizontally and vertically
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
    }
    
    // Create container for controls
    Container {
        
        // Arrange controls top-to-bottom
        layout: StackLayout {
            orientation: LayoutOrientation.TopToBottom
        }
        
        // Fill horizontally and vertically
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        // Create top divider
        Divider {
        }
        
        // Create container for controls
        Container {
            
            // Arrange controls left-to-right
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            
            // Set padding / margins
            topPadding: 10
            bottomPadding: 10
            leftPadding: 10
            rightPadding: 10
            
            // Define the title field
            Label {
                
                // Set properties
                id: titleField
                textStyle {
                    base: SystemDefaults.TextStyles.PrimaryText
                    textAlign: TextAlign.Left
                }
                
                // Fill up space
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                
                // Fill vertically
                verticalAlignment: VerticalAlignment.Fill
            }
            
            // Define the activity indicator
            ActivityIndicator {
                
                // Set properties
                id: activityField
                running: false
                
                // Use required space
                layoutProperties: StackLayoutProperties {
                    spaceQuota: -1
                }
                
                // Fill vertically
                verticalAlignment: VerticalAlignment.Fill
            }
        }
        
        // Create bottom divider
        Divider {
        }
    }
}
