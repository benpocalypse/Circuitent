using GLib;

public class Kicad_sch
{
    [Flags]
    private enum FileMode
    {
        UNKNOWN,
        HEADER,
        COMPONENT,
        WIRE,
        NO_CONNECT
    }

    public Header FileHeader;
    public List<Component> Components;
    public List<Wire> Wires;
    public List<NoConnect> NoConnects;
    public string Filename;

    private FileMode fMode;

    public Kicad_sch(string filename)
    {
        fMode = FileMode.UNKNOWN;

        if (filename != "")
        {
            Filename = filename;
            ParseFile(Filename);
        }
    }

    public void Print()
    {
        stdout.printf("Read %u components\n", Components.length ());

        foreach(Component c in Components)
        {
            stdout.printf ("Component %s:\n", c.Name);
            stdout.printf ("    Reference %s\n", c.Reference);
            stdout.printf ("    PositionX %i\n", c.PositionX);
            stdout.printf ("    PositionY %i\n", c.PositionY);

            foreach(Field f in c.Fields)
            {
                stdout.printf ("    Field %i: %s, %s, %d, %d\n", f.Number, f.Text, f.Orientation, f.PositionX, f.PositionY);
            }
        }

        stdout.printf("Read %u wires\n", Wires.length ());

        foreach(Wire w in Wires)
        {
            stdout.printf("Wire: %d, %d, %d, %d\n", w.StartX, w.StartY, w.EndX, w.EndY);
        }

    }


    private bool ParseFile(string filename)
    {
        FileHeader = new Header ();
        Components = new List<Component> ();
        Wires = new List<Wire> ();
        NoConnects = new List<NoConnect> ();

        var file = File.new_for_path (filename);

        if (!file.query_exists ())
        {
            stderr.printf ("File '%s' doesn't exist.\n", file.get_path ());
            return false;
        }

        try
        {
            var dis = new DataInputStream (file.read ());


            string line;

            // Read lines until end of file (null) is reached
            while ((line = dis.read_line (null)) != null)
            {
                string[] tokens = line.split(" ");

                if(tokens.length > 0)
                {
                    switch(tokens[0].up())
                    {
                        case "EESCHEMA":
                            fMode = FileMode.HEADER;
                            stdout.printf("%s\n", fMode.to_string());
                            break;

                        case "$ENDDESCR":
                            fMode = FileMode.UNKNOWN;
                            break;

                        case "$COMP":
                            fMode = FileMode.COMPONENT;
                            stdout.printf("%s\n", fMode.to_string());
                            ParseComponent(dis);
                            fMode = FileMode.UNKNOWN;
                            break;

                        case "WIRE":
                            if(tokens[1].up() == "WIRE")
                            {
                                fMode = FileMode.WIRE;
                                stdout.printf("%s\n", fMode.to_string());

                                var wireline = dis.read_line (null);
                                string[] wiretokens = wireline.split(" ");


                                Wires.append(new Wire(int.parse(wiretokens[0]),
                                                      int.parse(wiretokens[1]),
                                                      int.parse(wiretokens[2]),
                                                      int.parse(wiretokens[3])));


                                fMode = FileMode.UNKNOWN;
                            }
                            break;

                        case "NOCONN":
                            fMode = FileMode.NO_CONNECT;
                            NoConnects.append (new NoConnect (int.parse (tokens[2]), int.parse (tokens[3])));
                            fMode = FileMode.UNKNOWN;
                            break;

                        default:
                            break;
                    }
                }

                switch(fMode)
                {
                    case FileMode.COMPONENT:
                        break;
                }

                //stdout.printf("%s\n", fMode.to_string());
                //stdout.printf ("%s, tokens = %d\n", line, tokens.length);
            }
        }
        catch (Error e)
        {
            error ("%s", e.message);
        }

        return true;
    }

    private bool ParseComponent(DataInputStream dis)
    {
        Component newComponent = new Component();

        var line = dis.read_line (null);

        if(line != null)
        {
            var tokens = line.split(" ");

            while(tokens[0].up() != "$ENDCOMP")
            {
                stdout.printf("ParseComponent: %s\n", tokens[0]);

                switch(tokens[0].up())
                {
                    case "L":
                        newComponent.Name = tokens[1];
                        newComponent.Reference = tokens[2];
                        break;

                    case "P":
                        newComponent.PositionX = int.parse(tokens[1]);
                        newComponent.PositionY = int.parse(tokens[2]);
                        break;

                    case "F":
                        if(tokens.length == 11)
                            newComponent.AddField(int.parse(tokens[1]),
                                                  tokens[2], tokens[3],
                                                  int.parse(tokens[4]),
                                                  int.parse(tokens[5]),
                                                  int.parse(tokens[6]),
                                                  int.parse(tokens[7]),
                                                  tokens[8],
                                                  tokens[9],
                                                  tokens[10]
                                                  );
                        else
                            newComponent.AddField(int.parse(tokens[1]),
                                                  tokens[2], tokens[3],
                                                  int.parse(tokens[4]),
                                                  int.parse(tokens[5]),
                                                  int.parse(tokens[6]),
                                                  int.parse(tokens[7]),
                                                  tokens[8],
                                                  tokens[9],
                                                  ""
                                                  );
                        break;
                }

                line = dis.read_line (null);
                tokens = line.split(" ");
            }

            Components.append (newComponent);

            return true;
        }
        else
            return false;
    }
}

public class Header
{
    public string Version;
    public List<string> Libraries;
    public string Description;
}

public class Field
{
    public int Number;
    public string Text;
    public string Orientation;
    public int PositionX;
    public int PositionY;
    public int Dimension;
    public int Visibility;
    public string Justification;
    public string Style;
    public string Name;


    public Field()
    {
    }

    public Field.withContents(int num, string text, string orient, int px, int py,
                              int dim, int vis, string just, string style, string name)
    {
        Number = num;
        Text = text;
        Orientation = orient;
        PositionX = px;
        PositionY = py;
        Dimension = dim;
        Visibility = vis;
        Justification = just;
        Style = style;
        Name = name;
    }
}

public class Component
{
    public string Name;
    public string Reference;
    public int PositionX;
    public int PositionY;
    public List<Field> Fields;

    //public Component() {}

    public void AddField(int num, string text, string orient, int px, int py,
                         int dim, int vis, string just, string style, string name)
    {
        Field test = new Field();

        test.Number = num;
        test.Text = text;
        test.Orientation = orient;
        test.PositionX = px;
        test.PositionY = py;
        test.Dimension = dim;
        test.Visibility = vis;
        test.Justification = just;
        test.Style = style;
        test.Name = name;

        Fields.append(test);
    }
}

public class Wire
{
    public int StartX;
    public int StartY;
    public int EndX;
    public int EndY;

    public Wire(int sx, int sy, int ex, int ey)
    {
        StartX = sx;
        StartY = sy;
        EndX = ex;
        EndY = ey;
    }
}

public class NoConnect
{
    public int X;
    public int Y;

    public NoConnect(int x, int y)
    {
        X = x;
        Y = y;
    }
}
