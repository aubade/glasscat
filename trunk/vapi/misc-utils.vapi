public static string VERSION;
public static string DATADIR;
public static string GLASSCATDIR;

[CCode (cheader_filename = "time.h")]
public static uint time (out ulong tloc = null);
