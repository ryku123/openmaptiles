DROP TRIGGER IF EXISTS trigger_flag ON osm_hiking_poi_polygon;
DROP TRIGGER IF EXISTS trigger_refresh ON hiking_poi.updates;

-- etldoc:  osm_hiking_poi_polygon ->  osm_hiking_poi_polygon

CREATE OR REPLACE FUNCTION convert_poi_point() RETURNS VOID AS $$
BEGIN
  UPDATE osm_hiking_poi_polygon SET geometry=ST_PointOnSurface(geometry) WHERE ST_GeometryType(geometry) <> 'ST_Point';
  ANALYZE osm_hiking_poi_polygon;
END;
$$ LANGUAGE plpgsql;

SELECT convert_poi_point();

-- Handle updates

CREATE SCHEMA IF NOT EXISTS hiking_poi;

CREATE TABLE IF NOT EXISTS hiking_poi.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION hiking_poi.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO hiking_poi.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION hiking_poi.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh poi';
    PERFORM convert_poi_point();
    DELETE FROM hiking_poi.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_hiking_poi_polygon
    FOR EACH STATEMENT
    EXECUTE PROCEDURE hiking_poi.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON hiking_poi.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE hiking_poi.refresh();

-- etldoc:  osm_hiking_poi_polygon ->  osm_hiking_poi_polygon
UPDATE osm_hiking_poi_polygon SET geometry=topoint(geometry)
WHERE ST_GeometryType(geometry) <> 'ST_Point';

ANALYZE osm_hiking_poi_polygon;
