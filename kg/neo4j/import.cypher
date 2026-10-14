// Load with: cypher-shell -f import.cypher   (copy nodes.csv / relationships.csv into Neo4j's import/ folder)
CREATE CONSTRAINT entity_id IF NOT EXISTS FOR (e:Entity) REQUIRE e.id IS UNIQUE;
LOAD CSV WITH HEADERS FROM 'file:///nodes.csv' AS row
MERGE (e:Entity {id: row.`id:ID`}) SET e.label = row.label, e.type = row.type, e.mentions = toInteger(row.`mentions:int`)
WITH e, row CALL apoc.create.addLabels(e, [row.type]) YIELD node RETURN count(*);
LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
MATCH (s:Entity {id: row.`:START_ID`}), (o:Entity {id: row.`:END_ID`})
CALL apoc.merge.relationship(s, row.`:TYPE`, {}, {relation: row.relation, count: toInteger(row.`count:int`), drugs: split(row.drugs, ';'), sources: split(row.sources, ';')}, o) YIELD rel RETURN count(*);
// Without APOC: CREATE (s)-[:RELATED {type: row.`:TYPE`}]->(o) instead of apoc.merge.relationship.
