%writing .mlx file

fileID = fopen('script.mlx','w');
fprintf(fileID,'<!DOCTYPE FilterScript>\n<FilterScript>\n <filter name="Per Face Color Function">\n');
fprintf(fileID,'  <Param name="r" type="RichString" value="%s" tooltip="function to generate Red component. Expected Range 0-255" description="func r = "/>\n',r);
fprintf(fileID,'  <Param name="g" type="RichString" value="%s" tooltip="function to generate Green component. Expected Range 0-255" description="func g = "/>\n',g);
fprintf(fileID,'  <Param name="b" type="RichString" value="%s" tooltip="function to generate Blue component. Expected Range 0-255" description="func b = "/>\n',b);
fprintf(fileID,'  <Param name="a" type="RichString" value="255" tooltip="function to generate Alpha component. Expected Range 0-255" description="func alpha = "/>\n<Param name="onselected" type="RichBool" value="false" tooltip="if checked, only affects selected faces" description="only on selection"/>\n</filter>\n</FilterScript>');
fclose(fileID);