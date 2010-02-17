using GLib;
using Gtk;

public class Application : GLib.Object
{
	private static string config_dir;
	private SList<BaseWindow> window_list;
	private Unique.App instance;
	
	private int _win_count = 0;
	public int win_count {
		get { return _win_count; }
		set {
			_win_count = value;
			if ( _win_count <= 0 ) {
				Gtk.main_quit ();
			}
		}
	}
	
	public static string get_config_dir () {
		return config_dir;
	}
	
	[CCode (array_length = false)]
	public void run (string[] args) {
		Gtk.init (ref args);
		
		// set this envvar to anything before starting glasscat if you don't want it
		// to attach to your current instance during development.
		string suffix = Environment.get_variable ("GLASSCAT_INSTANCE");
		
		this.instance = new Unique.App ("org.gnome.glasscat" + suffix, null);
		
		// working around array length limitations in Vala
		// TODO: check if still necessary
		int num_args = -1;
		foreach (string s in args)
			num_args++;
		
		string[] urilist = new string[num_args];
		
		if ( this.instance.is_running ) {
			for (int i = 0; i < num_args; i++)
				urilist[i] = args[i + 1];
				
			if ( urilist.length == 0 ) {
				this.instance.send_message (Unique.Command.NEW, null);
			} else {
				var md = new Unique.MessageData ();
				md.set_uris (urilist);
				this.instance.send_message (Unique.Command.OPEN, md);
			}
			Gdk.notify_startup_complete ();
		} else {
			this.instance.message_received += on_message_received;
			bool first = true;
			int i = 0;
			foreach (string doc in args) {
				if (first) { first = false; continue; }
				open_document (doc);
				i++;
			}
			if ( i == 0 )
				open_project ();
		}
		
		if ( win_count > 0 ) {
			Gtk.AboutDialog.set_url_hook (url_hook);
			Gtk.AboutDialog.set_email_hook (email_hook);
			Gtk.main ();
		}
	}
	
	private void url_hook (AboutDialog dialog, string link) {
		try {
			Process.spawn_command_line_async ("gnome-open " + link);
		} catch (SpawnError e) {
			stdout.printf ("Error: %s\n", e.message);
		}
	}
	
	private void email_hook (AboutDialog dialog, string email) {
		try {
			Process.spawn_command_line_async ("gnome-open mailto:" + email);
		} catch (SpawnError e) {
			stdout.printf ("Error: %s\n", e.message);
		}
	}
	
	private void open_project () {
		var dialog = new Gtk.FileChooserDialog ("Create Project - Glasscat",
		                                         null,
		                                         FileChooserAction.SAVE,
		                                         STOCK_CANCEL, ResponseType.CANCEL,
		                                         "Create _Project", ResponseType.ACCEPT);
		
		var response = dialog.run ();
		
		if (response == ResponseType.ACCEPT) {
			dialog.hide ();
		
			this.win_count = this.win_count + 1;
			var w = new ProjectWindow (dialog.get_uri ());
			w.show_all ();
			window_list.append (w);
			w.destroy += w => { window_list.remove (w); win_count = win_count - 1; };
		} else {
			dialog.hide ();
		}
	}
	
	private void open_document (string uri) {
		foreach ( BaseWindow window in window_list ) {
			if ( window.is_document (uri) ) {
				window.present_with_time (time ());
				return;
			}
		}
	
		win_count = win_count + 1;
		
		BaseWindow w;
		if (g_content_type_guess (uri, new uchar[0], null) == "application/x-glasscat-project") {
			w = new ProjectWindow (uri);
		} else {
			w = new DocumentWindow (uri);
		}
		
		w.show_all ();
		w.present_with_time (time ());
		window_list.append (w);
		w.destroy += w => { window_list.remove (w); win_count--; };
	}
	
	static int main (string[] args) {
		config_dir = Environment.get_home_dir () + "/.gnome2/glasscat";
		
		DirUtils.create_with_parents ( Application.get_config_dir () + "/metadata/", 0750 );
		var app = new Application ();
		app.run (args);

		return 0;
	}
	
	private Unique.Response on_message_received (Unique.App instance,
	                                              int command, 
	                                              Unique.MessageData data, 
	                                              uint time_)
	{
		if ( command == Unique.Command.OPEN ) {
			foreach (string uri in data.get_uris ()) {
				open_document (uri);
			}
		} else if ( command == Unique.Command.NEW ) {
			open_project ();
		}
		
		return Unique.Response.OK;
	}
}
