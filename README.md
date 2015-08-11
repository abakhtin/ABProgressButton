## ABProgressButton

ABProgressButton provides functionality for creating custom animation of UIButton during processing some task. 
Should be created in IB as custom class UIButton to prevent title of the button appearing while animating.

# Example

Here is example of default button appearance with one custom image. Image can be found in the demo project. 

![alt tag](https://github.com/abakhtin/ABProgressButton/blob/master/ABProgressButtonDemo/GifExamples/example1.gif)

# Storyboards

I've got some problems with runtime rendering of control. In any case this properties are available for changing straigt in IB. 
For colors you can choose tintColor for view (whould be accepted for content and both borders if they are set to default) or for each component in separate.

![alt tag](https://github.com/abakhtin/ABProgressButton/blob/master/ABProgressButtonDemo/GifExamples/storyboard_properties.png)

# Install

To install to you project I would recommend you using CocoaPods.
Just add this line to podfile (uses repo as not ready for global pods list yet). Whould be updated if appear in pods repo. 

`pod 'ABProgressButton', :git => 'https://github.com/abakhtin/ABProgressButton.git'`

# Feedback

Please let me know what you would like improved, so I can fix it!

