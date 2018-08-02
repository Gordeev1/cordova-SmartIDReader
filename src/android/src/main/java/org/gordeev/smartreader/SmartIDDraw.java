/**
 Copyright (c) 2012-2017, Smart Engines Ltd
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 * Neither the name of the Smart Engines Ltd nor the names of its
 contributors may be used to endorse or promote products derived from this
 software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package org.gordeev.smartreader;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PointF;
import android.view.View;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import biz.smartengines.smartid.swig.MatchResultVector;
import biz.smartengines.smartid.swig.Quadrangle;
import biz.smartengines.smartid.swig.RecognitionResult;
import biz.smartengines.smartid.swig.SegmentationResult;
import biz.smartengines.smartid.swig.SegmentationResultVector;
import biz.smartengines.smartid.swig.StringVector;

public class SmartIDDraw extends View {

    /**
     * Smart IDDraw constructor
     */
    public SmartIDDraw(Context context) {
        super(context);

        // Initializing drawn quadrangles lists
        tpl_quads = new ArrayList<>();
        field_quads = new ArrayList<>();

        // Initializing paintbrushes
        tpl_paintbrush = new Paint();
        tpl_paintbrush.setColor(Color.WHITE);
        tpl_paintbrush.setStrokeWidth(5);

        field_paintbrush = new Paint();
        field_paintbrush.setColor(Color.WHITE);
        field_paintbrush.setStrokeWidth(3);
    }

    Paint tpl_paintbrush; ///< Template paintbrush
    Paint field_paintbrush; ///< Fields paintbrush
    private List<Quad> tpl_quads; ///< Drawn template quadrangles
    private List<Quad> field_quads; ///< Drawn field quadrangles

    /// DEPRECATED: list of template names not to be drawn
    private ArrayList<String> exclude_templates = new ArrayList<String>(Arrays.asList("mrzsearch_zone"));

    private float scale_w = 1.0f; ///< visualization scale ("width": horizontal)
    private float scale_h = 1.0f; ///< visualization scale ("height": vertical)

    /**
     * Drawn quadrangle
     */
    private class Quad {  // quad store class

        /**
         * Constructor from SDK quadrangle
         * @param quad - JNI quadrangle (of type biz.smartengines.smartid.swig.Quadrangle)
         */
        private Quad(Quadrangle quad) {
            lt.x = ( (float)quad.GetPoint(0).getX() ) * scale_w;
            lt.y = ( (float)quad.GetPoint(0).getY() ) * scale_h;
            rt.x = ( (float)quad.GetPoint(1).getX() ) * scale_w;
            rt.y = ( (float)quad.GetPoint(1).getY() ) * scale_h;
            rb.x = ( (float)quad.GetPoint(2).getX() ) * scale_w;
            rb.y = ( (float)quad.GetPoint(2).getY() ) * scale_h;
            lb.x = ( (float)quad.GetPoint(3).getX() ) * scale_w;
            lb.y = ( (float)quad.GetPoint(3).getY() ) * scale_h;
        }

        private PointF lt = new PointF(); ///< left-top point
        private PointF rt = new PointF(); ///< right-top point
        private PointF lb = new PointF(); ///< left-bottom point
        private PointF rb = new PointF(); ///< right-bottom point

        /**
         * Draws the quadrangle on the canvas
         * @param canvas - a canvas to draw on
         * @param paint  - a paintbrush to use
         */
        public void drawQuadrangle(Canvas canvas, Paint paint) {
            canvas.drawLine(lt.x, lt.y, rt.x, rt.y, paint);
            canvas.drawLine(rt.x, rt.y, rb.x, rb.y, paint);
            canvas.drawLine(rb.x, rb.y, lb.x, lb.y, paint);
            canvas.drawLine(lb.x, lb.y, lt.x, lt.y, paint);
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        for (int i = 0; i < tpl_quads.size(); i++) {
            tpl_quads.get(i).drawQuadrangle(canvas, tpl_paintbrush);
        }

        for (int i = 0; i < field_quads.size(); i++) {
            field_quads.get(i).drawQuadrangle(canvas, field_paintbrush);
        }
    }

    /**
     * Register new recognition result
     * @param result - JNI recognition result
     */
    public void showResult(RecognitionResult result) {
        tpl_quads.clear();
        field_quads.clear();

        if(result == null) {
            return;
        }

        // Quads for document templates
        MatchResultVector match = result.GetMatchResults();

        for (int i = 0; i < match.size(); i++) {
            String template_type = match.get(i).getTemplateType();

            if (exclude_templates.contains(template_type)) {
                continue;
            }

            tpl_quads.add(new Quad(match.get(i).getQuadrangle()));
        }

        // Quads for
        SegmentationResultVector segmentationResultVector = result.GetSegmentationResults();

        for (int j = 0; j < segmentationResultVector.size(); j++) {
            SegmentationResult segResult = segmentationResultVector.get(j);
            StringVector zoneNames = segResult.GetZoneNames();

            for (int k = 0; k < zoneNames.size(); k++) {
                Quadrangle quad = segResult.GetZoneQuadrangle(zoneNames.get(k));
                field_quads.add(new Quad(quad));
            }
        }
    }

    public void setRecognitionZone(int layout_width, int layout_height, int preview_width, int preview_height) {

        scale_w = (float)layout_width / (float)preview_width;
        scale_h = (float)layout_height / (float)preview_height;
    }
}
