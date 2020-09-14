import QtQuick 2.8
import QtGraphicalEffects 1.0

import "./kdefechconfs.js" as Utils

import QtQuick.Shapes 1.5

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras


Rectangle {
    id: root
    color: theme.backgroundColor

    width: 1920
    height: 1080

    property int stage

    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    
    property real highRadius: 36
    property real lowRadius: 8
    
    property double shadowOpacity : 0.05
    // property real baseAnimationTime : 1500
    // property real smallAnimationTime : baseAnimationTime*0.45

    property double baseAnimationTime : Math.max(units.longDuration*2, 1500) 
    property double smallAnimationTime : Math.max(units.shortDuration, baseAnimationTime*0.45)

    onStageChanged: {
        if(stage==1) {
            topSmoothX.duration = bottomSmoothX.duration = root.baseAnimationTime;
            topSmoothY.duration = bottomSmoothY.duration = root.smallAnimationTime;
        }

        if(stage==5) {
            revealer.running = true;
            topSmoothX.duration  = bottomSmoothX.duration = topSmoothY.duration = bottomSmoothY.duration = root.baseAnimationTime;
            topSmoothX.easing.type = bottomSmoothX.easing.type = topSmoothY.easing.type = bottomSmoothY.easing.type = Easing.InOutQuint;
        }
        
        if(stage==6) {
            twist.running = true;
        }
    }

    Item {
        id: content
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0
        anchors.fill: parent
        opacity: 1

        Text {
            anchors.centerIn: parent
            
            id:kyzen_text
            color:theme.buttonHoverColor
            text:"KYZEN"
            height:parent.height/3
            width:parent.height/3

            leftPadding: (width - kyzen_revealer.width) /2 
            rightPadding: leftPadding
            topPadding: (height - kyzen_revealer.height) /2
            bottomPadding: topPadding
            visible: !kyzen_text_shadow.visible
            transformOrigin: Item.Center

            font.weight: Font.Black
            font.pixelSize: parent.height * 64 / 1080
            font.capitalization: Font.AllUppercase

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMode: Text.HorizontalFit
            opacity: 0
            
            Component.onCompleted: Utils.fetchHostName()
        }

        DropShadow {
            id:kyzen_text_shadow
            source: kyzen_text   
            anchors.fill: kyzen_text
            property real startShadowY : root.height * ( source.fontInfo.pixelSize * 32 / source.font.pixelSize ) / 1080
            property real endShadowY : root.height * ( source.fontInfo.pixelSize * 8 / source.font.pixelSize ) / 1080
            verticalOffset: startShadowY
            visible: !root.softwareRendering 
            radius: lerp(root.highRadius, root.lowRadius, (verticalOffset - startShadowY) / (endShadowY - startShadowY))
            transformOrigin: source.transformOrigin
            scale:source.scale
            samples: 14
            spread: 0
            opacity:kyzen_text.opacity
            color: Qt.rgba(0, 0, 0, root.shadowOpacity) 
        }

        Rectangle {
            id: kyzen_revealer
            height:parent.height * 255.555 / 1080
            width:parent.width * 255.555 / 1920
            anchors.centerIn: parent
            visible: false
            transformOrigin: Item.Bottom
            rotation: 15
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: theme.backgroundColor }
                GradientStop { position: 1; color: "transparent" }
            }

        }

        Item {
            id: top_right_bracket

            height: parent.height/3
            width: parent.height/3
            transformOrigin: Item.Center

            property real y0: 0 + (height*0.25)
            property real y1: height

            x:lerp((width+parent.width), parent.width/2 - ((height) / 2), slopeStages(stage,0,1))
            y:lerp(y0, y1, slopeStages(stage,1,2))

            Shape {
                layer.enabled: true
                layer.samples: 12
                id:top_right_bracket_shape
                width:384
                height:384
               

                scale:(top_right_bracket.width / width)
                transformOrigin: Item.TopLeft
                visible: !top_right_bracket_shadow.visible
                
                anchors.left: parent.left
                anchors.top: parent.top

                ShapePath {
                    fillColor: theme.buttonFocusColor
                    strokeWidth:-1
                    startX: 128; startY: 128

                    PathSvg  {
                        path: "m328.34 136.31 55.69 55.676 0.01438-191.97-192 5.9079e-4 55.755 55.755h80.542z"
                    }
                }
            } 

            Behavior on x {
                PropertyAnimation {
                    duration: 0
                    easing.type: Easing.InOutQuint
                    id: topSmoothX
                }
            }    

            Behavior on y {
                PropertyAnimation {
                    duration: root.baseAnimationTime
                    easing.type: Easing.InOutQuint
                    id: topSmoothY
                }
            } 

            DropShadow {
                id: top_right_bracket_shadow
                anchors.fill: top_right_bracket_shape
                source: top_right_bracket_shape
                visible: !root.softwareRendering 
                property bool isAppearing: true

                property real startOffset: top_right_bracket.y1 - top_right_bracket.y0
                property real endOffset: 8
                
                verticalOffset:  isAppearing ? lerp( startOffset, endOffset, Math.max((top_right_bracket.y - top_right_bracket.y0) / (top_right_bracket.y1 - top_right_bracket.y0), 0 ) ) : 8
                radius: lerp(root.highRadius, root.lowRadius, (verticalOffset - startOffset) / (endOffset - startOffset))

                transformOrigin: source.transformOrigin
                scale:source.scale
                samples: 14
                spread: 0
                property real shadowOpacity: root.shadowOpacity

                color: Qt.rgba(0, 0, 0, shadowOpacity) // matches Breeze window decoration and desktopcontainment
            }
        } 

        Item {
            id: bottom_left_bracket
            // source: "images/kyzen-bracket.svg"
            height: parent.height/3
            width: parent.height/3
            
            transformOrigin: Item.Center
            property real y0: parent.height - (height*1.25)
            property real y1: height

            x:lerp(-0 - height, parent.width/2 - ((height) / 2), slopeStages(stage,2,3))
            y:lerp(y0, y1, slopeStages(stage,3,4))

            Shape {
                layer.enabled: true
                layer.samples: 12
                id:bottom_left_bracket_shape
                width:384
                height:384

                scale:(bottom_left_bracket.width / width)

                transformOrigin: Item.TopLeft
                visible: !bottom_left_bracket_shadow.visible
                
                anchors.left: parent.left
                anchors.top: parent.top

                ShapePath {
                    fillColor: theme.buttonFocusColor
                    strokeWidth:-1
                    startX: 128; startY: 128

                    PathSvg  {
                        path: "M 55.704209,247.70278 0.01438,192.02673 0,384 192.00084,383.99941 136.24602,328.24459 H 55.703619 Z"
                    }

                }

            }

            Behavior on x {
                PropertyAnimation {
                    duration: 0
                    easing.type: Easing.InOutQuint
                    id: bottomSmoothX
                }
            }    
            
            Behavior on y {
                PropertyAnimation {
                    duration: 0
                    easing.type: Easing.InOutQuint
                    id: bottomSmoothY
                }
            }

            DropShadow {
                id: bottom_left_bracket_shadow
                anchors.fill: bottom_left_bracket_shape
                source: bottom_left_bracket_shape
                visible: !root.softwareRendering 
                property bool isAppearing: true
                
                property real startOffset: -(bottom_left_bracket.y1 - bottom_left_bracket.y0)
                property real endOffset: 8
                property real shadowOpacity: root.shadowOpacity
                
                verticalOffset:  isAppearing ? lerp( startOffset, endOffset , Math.max((bottom_left_bracket.y - bottom_left_bracket.y0) / (bottom_left_bracket.y1 - bottom_left_bracket.y0), 0 ) ) : 8
                radius: lerp(root.highRadius, root.lowRadius, (verticalOffset - startOffset) / (endOffset - startOffset) )
                transformOrigin: source.transformOrigin
                scale:source.scale
                samples: 14
                spread: 0

                color: Qt.rgba(0, 0, 0, shadowOpacity) // matches Breeze window decoration and desktopcontainment
            }

        }

    }

    SequentialAnimation {
        id: revealer
        running: false
        
        ParallelAnimation {

            NumberAnimation {
                property: "height"
                target: kyzen_revealer
                to: 0
                duration: root.baseAnimationTime
                easing.type: Easing.InOutQuint
                easing.overshoot: 1.0
            }
            
            NumberAnimation {
                property: "scale"
                target: kyzen_text
                from: 1.05
                to: 1
                duration: root.baseAnimationTime
                easing.type: Easing.InOutQuint
                easing.overshoot: 1.0
            }
            
            NumberAnimation {
                property: "verticalOffset"
                target: kyzen_text_shadow
                from: kyzen_text_shadow.startShadowY
                to: kyzen_text_shadow.endShadowY
                duration: root.baseAnimationTime
                easing.type: Easing.InOutQuint
                easing.overshoot: 0
            }

             NumberAnimation {
                property: "font.letterSpacing"
                target: kyzen_text
                from:10*1.05
                to: 1
                duration: root.baseAnimationTime
                easing.type: Easing.InOutQuint
                easing.overshoot: 1.0
            }    
            
             PropertyAnimation  {
                property: "opacity"
                target: kyzen_text
                from: 0
                to: 1
                duration: root.baseAnimationTime
                easing.type: Easing.InOutQuint
                easing.overshoot: 1.0
            }   

             PropertyAnimation {
                property: "opacity"
                target: kyzen_revealer
                from: 1
                to: 0
                duration: root.baseAnimationTime
                easing.type: Easing.InOutQuint
                easing.overshoot: 1.0
            }

        }

    }

      SequentialAnimation {
        id: twist
        running: false

        ParallelAnimation {

            SequentialAnimation {

                ParallelAnimation {

                    NumberAnimation {
                        property: "rotation"
                        target: bottom_left_bracket
                        from: 0
                        to: -45
                        duration: root.smallAnimationTime
                        easing.type: Easing.InOutCirc
                        easing.overshoot: 1.0
                    }

                    NumberAnimation {
                        property:"shadowOpacity"
                        target: bottom_left_bracket_shadow
                        to: 0
                        duration: root.smallAnimationTime
                        easing.type: Easing.InOutCirc
                        easing.overshoot: 1.0
                    }

                }


                PropertyAction {
                    property:"isAppearing"
                    target: bottom_left_bracket_shadow
                    value: false

                }

                ScriptAction {
                    script: rotateVector(bottom_left_bracket, {x:bottom_left_bracket.width-bottom_left_bracket.parent.width, y:bottom_left_bracket.height-bottom_left_bracket.parent.height})
                }

            }

            SequentialAnimation {

                ParallelAnimation {

                    NumberAnimation {

                        property: "rotation"
                        target: top_right_bracket
                        from: 0
                        to: -45
                        duration: root.smallAnimationTime
                        easing.type: Easing.InOutCirc
                        easing.overshoot: 1.0
                    }  

                        
                    NumberAnimation {
                        property:"shadowOpacity"
                        target: top_right_bracket_shadow
                        to: 0
                        duration: root.smallAnimationTime
                        easing.type: Easing.InOutCirc
                        easing.overshoot: 1.0
                    }
  

                }

                PropertyAction {
                    property:"isAppearing"
                    target: top_right_bracket_shadow
                    value: false

                }

                ScriptAction {
                    script: rotateVector(top_right_bracket, {x:top_right_bracket.width+(top_right_bracket.parent.width/2), y:top_right_bracket.height+(top_right_bracket.parent.height/2) })
                }

            }

             NumberAnimation {
                property:"opacity"
                target: kyzen_text
                from: 1
                to: 0
                duration: root.baseAnimationTime
                easing.type: Easing.InOutQuint
                easing.overshoot: 1.0
            }  

            NumberAnimation {
                property: "verticalOffset"
                target: kyzen_text_shadow
                from: kyzen_text_shadow.endShadowY 
                to: kyzen_text_shadow.startShadowY
                duration: root.baseAnimationTime
                easing.type: Easing.InOutQuint
                easing.overshoot: 1.0
            }


            NumberAnimation {
                property: "scale"
                target: kyzen_text
                to: 1.05
                from: 1
                duration: root.baseAnimationTime
                easing.type: Easing.InOutQuint
                easing.overshoot: 1.0
            }

              NumberAnimation {
                property: "font.letterSpacing"
                target: kyzen_text
                to:20*1.05
                from: 1
                duration: root.baseAnimationTime
                easing.type: Easing.InOutQuint
                easing.overshoot: 1.0
            }

        }

    }

    function rotateVector(element, v) {
        var theta = ((element.rotation * ( element.scale < 0 ? -1 : 1 )  )* (Math.PI * 2)) / 360;

        var px, py;
        var cs = Math.cos(theta);
        var sn = Math.sin(theta);
        px = v.x * cs - v.y * sn;
        py = v.x * sn + v.y * cs;

        // element.x = px;
        element.y = py;
    }

    function lerp(a,b,n) {
        return (1 - n) * a + n * b;
    }

    function slopeStages(c,f,t) {
        return clamp(((c-f) * (1/(t-f))), 0, 1);  
    }

    function clamp(v, min, max) {
        return Math.min(Math.max(v, min), max);
    }

}
