
-- etldoc: layer_poi[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_poi | <z14_> z14_" ] ;

CREATE OR REPLACE FUNCTION layer_hiking_poi(bbox geometry, zoom_level integer, pixel_width numeric)
RETURNS TABLE(osm_id bigint, geometry geometry, name text) AS $$

  SELECT * FROM (
	SELECT osm_id, geometry, name FROM osm_hiking_poi_point
        UNION ALL
	SELECT osm_id, geometry, name FROM osm_hiking_poi_polygon
  ) AS poi_points
  WHERE geometry && bbox AND zoom_level >= 13;

$$ LANGUAGE SQL IMMUTABLE;
