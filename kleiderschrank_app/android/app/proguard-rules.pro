-dontwarn javax.lang.model.SourceVersion
-dontwarn javax.lang.model.element.Element
-dontwarn javax.lang.model.element.ElementKind
-dontwarn javax.lang.model.element.Modifier
-dontwarn javax.lang.model.type.TypeMirror
-dontwarn javax.lang.model.type.TypeVisitor
-dontwarn javax.lang.model.util.SimpleTypeVisitor8

# MediaPipe / TFLite: keep classes referenced from native code.
-keep class com.google.mediapipe.** { *; }
-keep class com.google.ai.** { *; }
-keep class org.tensorflow.** { *; }
