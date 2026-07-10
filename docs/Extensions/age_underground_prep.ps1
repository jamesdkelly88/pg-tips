$ErrorActionPreference = "Stop"
$source = @{
    stations = "https://raw.githubusercontent.com/neo4j-partners/neo4j-transport-for-london/refs/heads/main/datasets/london_transport_datasets_London_stations.csv"
    lines = "https://raw.githubusercontent.com/neo4j-partners/neo4j-transport-for-london/refs/heads/main/datasets/london_transport_datasets_London_tube_lines.csv"
}

$data = @{}

# Download source files
foreach ($f in $source.keys) {
    $d = Invoke-WebRequest -Uri $source[$f] -UseBasicParsing | ConvertFrom-Csv
    $data[$f] = $d
}

# Add station IDs
$id = 1
foreach($s in $data['stations'])
{
    $s | Add-Member -NotePropertyName id -NotePropertyValue $id
    $id++
}

# Export stations to csv
$data['stations'] | Select-Object -Property id, 
    @{ n = 'osX'; e = { $_.'OS X' }}, 
    @{ n = 'oxY'; e = { $_.'OS Y' }}, 
    @{ n = 'latitude'; e = { $_.Latitude }}, 
    @{ n = 'longitude'; e = { $_.Logitude }}, 
    @{ n = 'zone'; e = { $_.Zone }}, 
    @{ n = 'postcode'; e = { $_.Postcode }} | Export-Csv "nodes_station.csv"

# Add station IDs to edges
foreach($l in $data['lines'])
{
    $from = $data['Stations'].Where{ $_.Station -eq $l.From_Station }[0].id
    $to = $data['Stations'].Where{ $_.Station -eq $l.To_Station }[0].id
    $l | Add-Member -NotePropertyName "start_id" -NotePropertyValue $from
    $l | Add-Member -NotePropertyName "end_id" -NotePropertyValue $to 
}

# Group edges by type
$lines = $data['lines'] | Group-Object -Property Tube_Line

foreach($l in $lines)
{
    $l.Group | Select-Object -Property start_id,
        @{ n = 'start_vertex_type'; e = { 'Station' }}, 
        end_id,
        @{ n = 'end_vertex_type'; e = { 'Station' }} | Export-Csv "edges_$($l.Name.ToLower()).csv"
}
