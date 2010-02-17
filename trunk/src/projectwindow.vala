using GLib;
using Gtk;
using Gdk;

public class DocumentBuffer : GLib.Object
{
	public DocumentView view;
	public ScrolledWindow sw;
}

public class ProjectWindow : BaseWindow
{
	public string uri {get; set construct;}
	public Project project {get; set;}

	private Notebook notebook;
	private DocumentBuffer[] document_buffers = new DocumentBuffer[10];
	private ProjectTree project_tree;
	
	const TargetEntry[] targets = {
		{ "STRING", 0, 0 },
		{ "text/plain", 0, 0},
		{ "text/uri-list", 0, 0}
	};
	
	public ProjectWindow (string uri) {
		this.uri = uri;
	}

	construct {
		this.project = new Project (this.uri);
	
		populate_window ();
		
		drag_dest_set (this, DestDefaults.ALL, targets, DragAction.COPY);
		this.drag_data_received += on_drag_data_received;
		
		set_default_size (960, 700);
		
		string displayname = Filename.display_basename (Uri.unescape_string (this.uri, ""));
		set_title (displayname + " - Glasscat");
		
		try {
			var icon = IconTheme.get_default ().load_icon ("glasscat", 16, (IconLookupFlags)0);
			set_icon (icon);
		} catch (Error e) {
			stdout.printf ("Error: %s\n", e.message);
		} catch (GLib.FileError e) {
			stdout.printf ("Failed to load application icon: %s\n", e.message);
		}
	}
	
	private new void populate_window () {
		base.populate_window ();
		
		/* A hidden notebook with 10 DocumentView buffers. Set DocumentView to the first one. */
		this.notebook = new Notebook ();
		notebook.set_show_tabs (false);
		notebook.set_show_border (false);
		
		for (int i = 0; i < 10; i++) {
			document_buffers[i] = new DocumentBuffer ();
			document_buffers[i].view = new DocumentView ();
			var sw = new ScrolledWindow (null, null);
			sw.set_shadow_type (ShadowType.IN);
			sw.add (document_buffers[i].view);
			document_buffers[i].sw = sw;
			this.notebook.append_page (sw, null);
		}
		
		this.document_view = document_buffers[0].view;
		this.scrolled_window = document_buffers[0].sw;
		
		VBox vbox1 = new VBox (false, 0);
		vbox1.pack_start (notebook, true, true, 1);
		document_box.add (vbox1);	
		
		/* The Project Tree Side Bar */
		var st = new ScrolledWindow (null, null);
		st.shadow_type = ShadowType.IN;
		project_tree = new ProjectTree ();
		st.add (project_tree);
		
		/* The Buffer List */
		var frame = new Frame (null);
		frame.shadow_type = ShadowType.IN;
		BufferList buffer_list = new BufferList (this);
		frame.add (buffer_list);
		
		VBox vbox2 = new VBox (false, 0);
		vbox2.pack_start (st, true, true, 1);
		vbox2.pack_start (frame, false, true, 3);
		
		pane.add1 (vbox2);
	}
	
	void on_drag_data_received (ProjectWindow win, Gdk.DragContext context, int x, int y, Gtk.SelectionData selection_data, uint info, uint time_) {
		stdout.printf ("drag data received: %s\n", selection_data.get_text ());
		project_tree.add_files (selection_data.get_text ());
	}
}
