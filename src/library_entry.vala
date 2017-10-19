namespace com.github.benpocalypse.circuitent
{
    public class LibraryEntry
    {
        public string Reference;
        public string Value;
        public string Footprint;
        public string Datasheet;
        public string PartNumber;

        public LibraryEntry (string r,
                             string v,
                             string f,
                             string d,
                             string p)
        {
            this.Reference = r;
            this.Value = v;
            this.Footprint = f;
            this.Datasheet = d;
            this.PartNumber = p;
        }
    }
}

