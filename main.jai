#import "Basic";
#import "File";

STATIONS :: string.[
	"Paris",
	"Londres",
	"Bordeaux",
	"Twitch",
	"Twitter"
];

main :: () {
	sb: String_Builder;
	init_string_builder(*sb, 1000000 * 100);
	idx := 0;
	for 1..1000000 {
		if it != 1
			print_to_builder(*sb, "\n");

		idx += 1;
		idx *= idx;
		idx %= STATIONS.count;
		print_to_builder(*sb, "%;%", STATIONS[idx], idx * 10 + idx);
	}

	write_entire_file("input.txt", *sb);
	input, ok := read_entire_file("input.txt");
}