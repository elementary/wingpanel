/*-
 * Copyright (c) 2015 Wingpanel Developers (http://launchpad.net/wingpanel)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
	The method for calculating the background information and the classes that are
	related to it are copied from Gala.DBus.
*/

namespace WingpanelInterface.Utils {
	private const double SATURATION_WEIGHT = 1.5;
	private const double WEIGHT_THRESHOLD = 1.0;
	private const double MIN_VARIANCE = 50;
	private const double MIN_LUM = 25;

	private class DummyOffscreenEffect : Clutter.OffscreenEffect {
		public signal void done_painting ();

		public override void post_paint () {
			base.post_paint ();
			done_painting ();
		}
	}

	public struct ColorInformation {
		double average_red;
		double average_green;
		double average_blue;
		double mean;
		double variance;
	}

	public async ColorInformation get_background_color_information (Gala.WindowManager wm, int monitor,
			int reference_x, int reference_y, int reference_width, int reference_height) throws DBusError {
		var background = wm.background_group.get_child_at_index (monitor);

		if (background == null)
			throw new DBusError.INVALID_ARGS ("Invalid monitor requested: %i".printf (monitor));

		var effect = new DummyOffscreenEffect ();
		background.add_effect (effect);

		var tex_width = (int)background.width;
		var tex_height = (int)background.height;

		int x_start = reference_x;
		int y_start = reference_y;
		int width = int.min (tex_width - reference_x, reference_width);
		int height = int.min (tex_height - reference_y, reference_height);

		if (x_start > tex_width || x_start > tex_height || width <= 0 || height <= 0)
			throw new DBusError.INVALID_ARGS ("Invalid rectangle specified: %i, %i, %i, %i".printf (x_start, y_start, width, height));

		double variance = 0, mean = 0, rTotal = 0, gTotal = 0, bTotal = 0;
		ulong paint_signal_handler = 0;

		paint_signal_handler = effect.done_painting.connect (() => {
			SignalHandler.disconnect (effect, paint_signal_handler);
			background.remove_effect (effect);

			var texture = (Cogl.Texture)effect.get_texture ();
			var pixels = new uint8[texture.get_width () * texture.get_height () * 4];

			CoglFixes.texture_get_data (texture, Cogl.PixelFormat.BGRA_8888_PRE, 0, pixels);

			int size = width * height;

			double mean_squares = 0;
			double pixel = 0;

			double max, min, score, delta, scoreTotal = 0, rTotal2 = 0, gTotal2 = 0, bTotal2 = 0;

			// code to calculate weighted average color is copied from
			// plank's lib/Drawing/DrawingService.vala average_color()
			// http://bazaar.launchpad.net/~docky-core/plank/trunk/view/head:/lib/Drawing/DrawingService.vala
			for (int y = y_start; y < height; y++) {
				for (int x = x_start; x < width; x++) {
					int i = y * width * 4 + x * 4;

					uint8 r = pixels[i];
					uint8 g = pixels[i + 1];
					uint8 b = pixels[i + 2];

					pixel = (0.3 * r + 0.6 * g + 0.11 * b) - 128f;

					min = uint8.min (r, uint8.min (g, b));
					max = uint8.max (r, uint8.max (g, b));

					delta = max - min;

					// prefer colored pixels over shades of grey
					score = SATURATION_WEIGHT * (delta == 0 ? 0.0 : delta / max);

					rTotal += score * r;
					gTotal += score * g;
					bTotal += score * b;
					scoreTotal += score;

					rTotal += r;
					gTotal += g;
					bTotal += b;

					mean += pixel;
					mean_squares += pixel * pixel;
				}
			}

			scoreTotal /= size;
			bTotal /= size;
			gTotal /= size;
			rTotal /= size;

			if (scoreTotal > 0.0) {
				bTotal /= scoreTotal;
				gTotal /= scoreTotal;
				rTotal /= scoreTotal;
			}

			bTotal2 /= size * uint8.MAX;
			gTotal2 /= size * uint8.MAX;
			rTotal2 /= size * uint8.MAX;

			// combine weighted and not weighted sum depending on the average "saturation"
			// if saturation isn't reasonable enough
			// s = 0.0 -> f = 0.0 ; s = WEIGHT_THRESHOLD -> f = 1.0
			if (scoreTotal <= WEIGHT_THRESHOLD) {
				var f = 1.0 / WEIGHT_THRESHOLD * scoreTotal;
				var rf = 1.0 - f;

				bTotal = bTotal * f + bTotal2 * rf;
				gTotal = gTotal * f + gTotal2 * rf;
				rTotal = rTotal * f + rTotal2 * rf;
			}

			// there shouldn't be values larger then 1.0
			var max_val = double.max (rTotal, double.max (gTotal, bTotal));

			if (max_val > 1.0) {
				bTotal /= max_val;
				gTotal /= max_val;
				rTotal /= max_val;
			}

			mean /= size;
			mean_squares *= mean_squares / size;

			variance = Math.sqrt (mean_squares - mean * mean) / (double) size;

			get_background_color_information.callback ();
		});

		background.queue_redraw ();

		yield;

		return {rTotal, gTotal, bTotal, mean, variance};
	}

	public async bool background_needed (Gala.WindowManager wm, int screen, int panel_height) {
		Gdk.Rectangle monitor_geometry;
		ColorInformation? color_info = null;

		Gdk.Screen.get_default ().get_monitor_geometry (screen, out monitor_geometry);

		try {
			color_info = yield get_background_color_information (wm, screen, 0, 0, monitor_geometry.width, panel_height);
		} catch (Error e) {
			warning (e.message);

			return false;
		}

		return color_info != null && (color_info.mean > MIN_LUM || color_info.variance > MIN_VARIANCE);
	}
}
