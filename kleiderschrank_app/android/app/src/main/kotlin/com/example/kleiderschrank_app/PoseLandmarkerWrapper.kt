package com.example.kleiderschrank_app

import android.content.Context
import android.graphics.Bitmap
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import com.google.mediapipe.tasks.components.containers.NormalizedLandmark

object PoseLandmarkerWrapper {

    // BlazePose Landmark-Indizes (33 Punkte)
    private const val LEFT_WRIST = 15
    private const val RIGHT_WRIST = 16
    private const val LEFT_HIP = 23
    private const val RIGHT_HIP = 24
    private const val LEFT_KNEE = 25
    private const val RIGHT_KNEE = 26
    private const val LEFT_ANKLE = 27
    private const val RIGHT_ANKLE = 28

    private var landmarker: PoseLandmarker? = null

    private fun ensureInit(context: Context) {
        if (landmarker != null) return

        val baseOptions = BaseOptions.builder()
            .setModelAssetPath("pose_landmarker_lite.task")
            .build()

        val options = PoseLandmarker.PoseLandmarkerOptions.builder()
            .setBaseOptions(baseOptions)
            .setRunningMode(RunningMode.IMAGE)
            .setNumPoses(1)
            // toleranter, damit Hip/Knee nicht so oft "weg" sind
            .setMinPoseDetectionConfidence(0.3f)
            .setMinPosePresenceConfidence(0.3f)
            .setMinTrackingConfidence(0.3f)
            .build()

        landmarker = PoseLandmarker.createFromOptions(context, options)
    }

        private fun pt(p: NormalizedLandmark, bitmapW: Int, bitmapH: Int): Map<String, Double> {
        fun asDouble(x: Any?): Double = when (x) {
            is Number -> x.toDouble()
            is String -> x.toDoubleOrNull() ?: 0.0
            else -> 0.0
        }

        // MediapPipe Landmark-Getter können je nach Artifact/IDE als Float/Double erscheinen.
        // Wir holen Werte defensiv.
        val x = asDouble(runCatching { p.x() }.getOrNull())
        val y = asDouble(runCatching { p.y() }.getOrNull())
        val v = asDouble(runCatching { p.visibility() }.getOrNull())
        val pr = asDouble(runCatching { p.presence() }.getOrNull())

        return mapOf(
            "x" to (x * bitmapW.toDouble()),
            "y" to (y * bitmapH.toDouble()),
            "v" to v,
            "pr" to pr,
        )
    }


    fun detect(context: Context, bitmap: Bitmap): Map<String, Map<String, Double>> {
        ensureInit(context)

        val mpImage = BitmapImageBuilder(bitmap).build()
        val result: PoseLandmarkerResult = landmarker!!.detect(mpImage)

        if (result.landmarks().isEmpty()) {
            throw IllegalStateException("No pose detected")
        }

        val lm = result.landmarks()[0] // erste Person

        val out = mutableMapOf<String, Map<String, Double>>()
        out["leftHip"] = pt(lm[LEFT_HIP], bitmap.width, bitmap.height)
        out["rightHip"] = pt(lm[RIGHT_HIP], bitmap.width, bitmap.height)
        out["leftKnee"] = pt(lm[LEFT_KNEE], bitmap.width, bitmap.height)
        out["rightKnee"] = pt(lm[RIGHT_KNEE], bitmap.width, bitmap.height)

        out["leftAnkle"] = pt(lm[LEFT_ANKLE], bitmap.width, bitmap.height)
        out["rightAnkle"] = pt(lm[RIGHT_ANKLE], bitmap.width, bitmap.height)
        out["leftWrist"] = pt(lm[LEFT_WRIST], bitmap.width, bitmap.height)
        out["rightWrist"] = pt(lm[RIGHT_WRIST], bitmap.width, bitmap.height)

        return out
    }
}
