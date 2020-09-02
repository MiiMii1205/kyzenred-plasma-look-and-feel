import QtQuick 2.5
import QtGraphicalEffects 1.0

import "./kdefechconfs.js" as Utils

Rectangle {
    id: root
    color: "#262626"

    property int stage

    property double shadowOpacity : 0.05
    property double baseAnimationTime : 1500
    property double smallAnimationTime : baseAnimationTime*0.45

    onStageChanged: {
        if(stage==1) {
            topSmoothX.duration = bottomSmoothX.duration = root.baseAnimationTime;
            bottomShadowSmoothOpacity.duration = topShadowSmoothOpacity.duration = topShadowSmoothY.duration = bottomShadowSmoothY.duration = topSmoothY.duration = bottomSmoothY.duration = root.smallAnimationTime;
        }

        if(stage==5) {
            revealer.running = true;
            bottomShadowSmoothOpacity.duration = topShadowSmoothOpacity.duration = topSmoothX.duration = topShadowSmoothY.duration = bottomShadowSmoothY.duration = bottomSmoothX.duration = topSmoothY.duration = bottomSmoothY.duration = root.baseAnimationTime;
            bottomShadowSmoothOpacity.easing.type = topShadowSmoothOpacity.easing.type = topSmoothX.easing.type = topShadowSmoothY.easing.type = bottomShadowSmoothY.easing.type = bottomSmoothX.easing.type = topSmoothY.easing.type = bottomSmoothY.easing.type = Easing.InOutQuint;
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

        TextMetrics {
            id: units
            text: "M"
            property int gridUnit: boundingRect.height
            property int largeSpacing: units.gridUnit
            property int smallSpacing: Math.max(2, gridUnit/4)
        }

        Text {
            opacity: 0
            id:kyzen_text
            anchors.centerIn: parent
            color:"black"
            text:"KYZEN"
            font.weight: Font.Black
            font.pixelSize: parent.height * 64 / 1080
            horizontalAlignment: Text.AlignHCenterl
            verticalAlignment: Text.AlignVCenter

            Text {
                id:kyzen_text_shadow
                property double startShadowY : parent.parent.height * 16 / 1080
                property double endShadowY : parent.parent.height * 8 / 1080
                y: startShadowY
                x: 0
                z:-1
                text:parent.text
                font.weight:parent.font.weight
                font.pixelSize: parent.font.pixelSize
                horizontalAlignment:  parent.horizontalAlignment
                verticalAlignment: parent.verticalAlignment
                color:"black"
            }

        }

        Rectangle {
            id: kyzen_revealer
            height:parent.height * 255.555 / 1080
            width:parent.width * 255.555 / 1920
            anchors.centerIn: parent
            transformOrigin: Item.Bottom
            rotation: 15
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: "#262626" }
                GradientStop { position: 1; color: "transparent" }
            }

        }

        Image {
            id: top_right_bracket
            source: "images/kyzen-bracket.svg"
            sourceSize.height: parent.height/3
            sourceSize.width: parent.height/3
            transformOrigin: Item.Center

            x:lerp((width+parent.width), parent.width/2 - ((height) / 2), slopeStages(stage,0,1))
            y:lerp(0 + (height*0.25), height, slopeStages(stage,1,2))

            Behavior on x {

                PropertyAnimation {
                    duration: 0
                    easing.type: Easing.InOutQuint
                    id: topSmoothX
                }

            }    

            Behavior on y {

                PropertyAnimation {
                    duration: 0
                    easing.type: Easing.OutBack
                    id: topSmoothY
                }

            } 

            Image {
                id: top_right_bracket_shadow
                source: "images/kyzen-bracket.svg"
                sourceSize.height: parent.height
                sourceSize.width: parent.width
                transformOrigin: Item.Center
                y:( parent.parent.height * 8 / 1080 )
                z:-1

                opacity:lerp(0,root.shadowOpacity, slopeStages(stage,1,2))

                Behavior on y {

                    PropertyAnimation {
                        duration: 0
                        easing.type: Easing.OutBack
                        easing.overshoot: 0
                        id: topShadowSmoothY
                    }

                }    
                
                Behavior on opacity {

                    PropertyAnimation {
                        duration: 0
                        easing.type: Easing.OutBack
                        easing.overshoot: 0
                        id: topShadowSmoothOpacity
                    }

                }   

            } 

        } 
        
        Image {
            id: bottom_left_bracket
            source: "images/kyzen-bracket.svg"
            sourceSize.height: parent.height/3
            sourceSize.width: parent.height/3
            scale:-1
            transformOrigin: Item.Center

            x:lerp(-0 - height, parent.width/2 - ((height) / 2), slopeStages(stage,2,3))
            y:lerp(parent.height - (height*1.25), height, slopeStages(stage,3,4))

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
                    easing.type: Easing.OutBack
                    id: bottomSmoothY
                }

            }

            Image {
                id: bottom_left_bracket_shadow
                source: "images/kyzen-bracket.svg"
                sourceSize.height: parent.height
                sourceSize.width: parent.width
                transformOrigin: Item.Center
                opacity:lerp(0,root.shadowOpacity, slopeStages(stage,3,4))
                y:-( parent.parent.height * 8 / 1080 )
                z:-1

                Behavior on y {

                    PropertyAnimation {
                        duration: 0
                        easing.type: Easing.OutBack
                        easing.overshoot: 0
                        id: bottomShadowSmoothY
                    }

                }    
                
                Behavior on opacity {

                    PropertyAnimation {
                        duration: 0
                        easing.type: Easing.OutBack
                        easing.overshoot: 0
                        id: bottomShadowSmoothOpacity
                    }

                }   

            } 

        }

        Component.onCompleted: Utils.makeKDERequest();

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
                property: "y"
                target: kyzen_text_shadow
                from: kyzen_text_shadow.startShadowY
                to: kyzen_text_shadow.endShadowY
                duration: root.baseAnimationTime
                easing.type: Easing.InOutQuint
                easing.overshoot: 1.0
            }

            NumberAnimation {
                property: "scale"
                target: kyzen_text_shadow
                from: 1.05
                to: 1
                duration: root.baseAnimationTime
                easing.type: Easing.InOutQuint
                easing.overshoot: 1.0
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
            
            NumberAnimation {
                property: "font.letterSpacing"
                target: kyzen_text_shadow
                from:10*1.05
                to: 1
                duration: root.baseAnimationTime
                easing.type: Easing.InOutQuint
                easing.overshoot: 1.0
            }
            
             OpacityAnimator {
                target: kyzen_text
                from: 0
                to: 1
                duration: root.baseAnimationTime
                easing.type: Easing.InOutQuint
                easing.overshoot: 1.0
            }   

             OpacityAnimator {
                target: kyzen_text_shadow
                from: 0
                to: root.shadowOpacity
                duration: root.baseAnimationTime
                easing.type: Easing.InOutQuint
                easing.overshoot: 1.0
            }  

             OpacityAnimator {
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

                    OpacityAnimator {
                        target: bottom_left_bracket_shadow
                        from: root.shadowOpacity
                        to: 0
                        duration: root.smallAnimationTime
                    }  

                }

                ScriptAction {
                    script: rotateVector(bottom_left_bracket, {x:top_right_bracket.width+top_right_bracket.parent.width, y:top_right_bracket.height+top_right_bracket.parent.height})
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

                    OpacityAnimator {
                        target: top_right_bracket_shadow
                        from: root.shadowOpacity
                        to: 0
                        duration: root.smallAnimationTime
                    }  

                }

                ScriptAction {
                    script: rotateVector(top_right_bracket, {x:top_right_bracket.width+top_right_bracket.parent.width, y:top_right_bracket.height+top_right_bracket.parent.height })
                }

            }

             OpacityAnimator {
                target: kyzen_text
                from: 1
                to: 0
                duration: root.baseAnimationTime
                easing.type: Easing.InOutCirc
                easing.overshoot: 1.0
            }  

              NumberAnimation {
                property: "font.letterSpacing"
                target: kyzen_text
                to:20*1.05
                from: 1
                duration: root.baseAnimationTime
                easing.type: Easing.InOutCirc
                easing.overshoot: 1.0
            }

             OpacityAnimator {
                target: kyzen_text_shadow
                from: root.shadowOpacity
                to: 0
                duration: root.baseAnimationTime
                easing.type: Easing.InOutCirc
                easing.overshoot: 1.0
            }  

              NumberAnimation {
                property: "font.letterSpacing"
                target: kyzen_text_shadow
                to:20*1.05
                from: 1
                duration: root.baseAnimationTime
                easing.type: Easing.InOutCirc
                easing.overshoot: 1.0
            }

        }

    }

    function rotateVector(element, v) {
        var theta = ((element.rotation *  ( element.scale < 0 ? -1 : 1 )  )* (Math.PI * 2)) / 360;

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
