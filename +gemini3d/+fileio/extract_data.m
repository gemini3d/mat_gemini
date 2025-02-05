function extract_data(archive, odir)
arguments
  archive (1,1) string {mustBeFile}
  odir (1,1) string {mustBeNonzeroLengthText}
end

[~,~,arc_type] = fileparts(archive);

stdlib.makedir(odir)

switch arc_type
  case ".zip", unzip(archive, data_dir)
  % old zip files had vestigial folder of same name instead of just files
  case ".tar", untar(archive, odir)
  case {".zst", ".zstd"}, gemini3d.extract_zstd(archive, odir)
  otherwise, error("gemini3d:fileio:extract_data:ValueError", "unknown reference archive type: " + arc_type)
end
