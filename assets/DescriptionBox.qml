import bb.cascades 1.0

Container {
    
    // Define property aliases
    property alias text: textField.text
    
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
    
    // Create a separate container for the label
    Container {
        
        // Arrange children using docking
        layout: DockLayout {
        }
        
        // Set padding / margins
        topPadding: 10
        bottomPadding: 10
        leftPadding: 10
        rightPadding: 10
        
        // Fill horizontally and vertically
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        // Define the text area
        Label {
            
            // Set properties
            id: textField
            multiline: true
            textStyle {
                base: SystemDefaults.TextStyles.BodyText
                textAlign: TextAlign.Center
            }
            
            // Fill horizontally and vertically
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
        }
    }
}
