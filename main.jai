#import "Basic";
#import "File";
#import "Random";
#import "String";
#import "Math";
#import "Hash";
#import "Hash_Table";

generate_file :: () {
	city_name_raw, ok := read_entire_file("input/city_name.txt");
	if !ok {
		print("Failed to read city_name.txt\n");
		return;
	}

	city_name := split(city_name_raw, "\n",, temp);
	if city_name.count == 0 {
		print("Failed to split city_name.txt\n");
		return;
	}
	if city_name[city_name.count - 1].count == 0 {
		city_name.count -= 1;
	}

	sb: String_Builder;
	init_string_builder(*sb, 1000000 * 100);
	for 1..1000000 {
		if it != 1
			print_to_builder(*sb, "\n");

		idx := cast(int) (random_get_zero_to_one_open_new() * city_name.count);
		temperature := random_get_within_range(-20, +60);
		temperature = cast(int) (temperature * 100) / 100.0;
		print_to_builder(*sb, "%;%", city_name[idx], temperature);
	}

	write_entire_file("input.txt", *sb);
}

// #run generate_file();


// Get the input file here
// https://drive.usercontent.google.com/download?id=1HEyNw4M453n0tnuaAm9nwaCiLydQYnpo&export=download&authuser=0

// History of runtime
// 07/01 128851.791 ms

Station :: struct {
	min: float32 = -FLOAT32_MAX;
	max: float32 = +FLOAT32_MAX;
	sum: float32 = 0;
	cnt: int = 0;
}

main :: () {
	t0 := current_time_monotonic();
	defer {
		t1 := current_time_monotonic();
		print("Ran in % ms\n", to_float64_seconds(t1 - t0) * 1000);
	}
	station_names: [..] string;
	array_reserve(*station_names, 1000);

	stations: [..] Station;
	array_reserve(*stations, 1000);

	compare_fn :: (a: string, b: string) -> bool {
		if a.count != b.count
			return false;
		return memcmp(a.data, b.data, a.count) == 0;
	}
	stations_map: Table(string, Station, djb2_hash, compare_fn);
	file_map, ok2 := map_file("measurements/measurements.txt");
	measurements := string.{ data = file_map.data.data, count = file_map.data.count };

	idx := 0;
	n := 0;
	while idx < measurements.count {
		n += 1;
		next_new_line_idx := find_index_from_left(measurements, #char "\n", idx);
		defer {
			idx = next_new_line_idx + 1;
		}
		if next_new_line_idx < 0 {
			break;
		}

		line := string.{
			data = measurements.data + idx, count = next_new_line_idx - idx
		};

		semi_colon_idx := find_index_from_left(line, #char ";", 0);
		if semi_colon_idx < 0 {
			continue;
		}

		station_name := string.{
			data = line.data, count = semi_colon_idx
		};
		temperature_str := string.{
			data = line.data + semi_colon_idx + 1, count = line.count - semi_colon_idx - 1
		};

		temperature := string_to_float(temperature_str);

		station_found := table_find_pointer(*stations_map, station_name);
		if !station_found {
			new_station: Station;
			new_station.cnt = 1;
			new_station.sum = temperature;
			new_station.min = temperature;
			new_station.max = temperature;
			table_add(*stations_map, station_name, new_station);
		} else {
			station_found.cnt += 1;
			station_found.sum += temperature;
			station_found.min = min(station_found.min, temperature);
			station_found.max = max(station_found.max, temperature);
		}

		if (n % (100 * 1000 * 1000)) == 0 {
			print("Read % lines\n", n);
			for stations_map {
				print("    %: %\n", it_index, it);
			}
		}
	}

}