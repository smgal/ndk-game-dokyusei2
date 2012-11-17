
package com.avej.dokyusei2;

import android.app.Activity;
import android.os.Bundle;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Rect;

public class Dokyusei2 extends Activity
{
	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);

		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);

		setContentView(new Dokyusei2View(this));
	}
	
	@Override
	public boolean onTouchEvent(MotionEvent event)
	{
		int motion_event = event.getAction(); 

		if (motion_event == MotionEvent.ACTION_DOWN)
		{
			int ax = (int)event.getX();
			int ay = (int)event.getY();

			Dokyusei2View.s_touch_x = ax;
			Dokyusei2View.s_touch_y = ay;
		}
		else if (motion_event == MotionEvent.ACTION_MOVE)
		{
			int ax = (int)event.getX();
			int ay = (int)event.getY();

			Dokyusei2View.s_touch_x = ax;
			Dokyusei2View.s_touch_y = ay;
		}
		else if (motion_event == MotionEvent.ACTION_UP)
		{
			Dokyusei2View.s_touch_x = -1;
			Dokyusei2View.s_touch_y = -1;
		}

		return true;
	}

    /* load our native library */
	static
	{
		System.loadLibrary("dokyusei2");
	}
}

class Dokyusei2View extends View
{
	static int s_touch_x;
	static int s_touch_y;

	private Bitmap m_bitmap;
	private Rect   m_src_rect;
	private Rect   m_dst_rect;
	private double m_scaling_factor;
	private long   m_start_time;

	/* implementend by libdokyusei2.so */
	private static native void initDokyusei2(String resource_path);
	private static native void renderDokyusei2(Bitmap bitmap, long time_ms, int motion_x, int motion_y);

	public Dokyusei2View(Context context)
	{
		super(context);

		int BUFFER_WIDTH = 640;
		int BUFFER_HEIGHT = 400;
		
		m_src_rect = new Rect(0, 0, BUFFER_WIDTH, BUFFER_HEIGHT);

		m_bitmap = Bitmap.createBitmap(BUFFER_WIDTH, BUFFER_HEIGHT, Bitmap.Config.ARGB_8888);

		m_start_time = System.currentTimeMillis();

		PackageInfo info = null;

		try
		{
			info = getContext().getPackageManager().getPackageInfo("com.avej.dokyusei2", 0);
		}
		catch (NameNotFoundException e)
		{
			Log.e("SMGAL", e.toString());
			return;
		}
		
		initDokyusei2(info.applicationInfo.sourceDir);
	}

	private String  getString(int appName) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override protected void onDraw(Canvas canvas)
	{
		if (m_dst_rect == null)
		{
			int canvas_width = canvas.getWidth();
			int canvas_height = canvas.getHeight();

			if (m_src_rect.width() * canvas_height > m_src_rect.height() * canvas_width)
			{
				int dst_width = canvas_width;
				int dst_height = m_src_rect.height() * canvas_width / m_src_rect.width();
				int dst_x = (canvas_width - dst_width) / 2;
				int dst_y = (canvas_height - dst_height) / 2;
				
				m_dst_rect = new Rect(dst_x, dst_y, dst_x + dst_width, dst_y + dst_height);
			}
			else
			{
				int dst_width = m_src_rect.width() * canvas_height / m_src_rect.height();
				int dst_height = canvas_height;
				int dst_x = (canvas_width - dst_width) / 2;
				int dst_y = (canvas_height - dst_height) / 2;

				m_dst_rect = new Rect(dst_x, dst_y, dst_x + dst_width, dst_y + dst_height);
			}

			m_scaling_factor = 1.0 * m_dst_rect.width() / m_src_rect.width();
		}

		{
			int revised_touch_x = s_touch_x;
			int revised_touch_y = s_touch_y;

			if (revised_touch_x >= 0 && revised_touch_y >= 0 )
			{
				revised_touch_x -= m_dst_rect.left;
				revised_touch_y -= m_dst_rect.top;
				
				revised_touch_x = (int)((double)revised_touch_x / m_scaling_factor); 
				revised_touch_y = (int)((double)revised_touch_y / m_scaling_factor); 
			}

			renderDokyusei2(m_bitmap, System.currentTimeMillis() - m_start_time, revised_touch_x, revised_touch_y);
		}

		canvas.drawBitmap(m_bitmap, m_src_rect, m_dst_rect, null);

		// force a redraw, with a different time-based pattern.
		invalidate();
	}
}
