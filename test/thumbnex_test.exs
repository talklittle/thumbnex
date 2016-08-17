defmodule ThumbnexTest do
  use ExUnit.Case
  doctest Thumbnex

  @fixture_video Path.join(__DIR__, "fixtures/cat_fade_in.mp4")
  @fixture_image Path.join(__DIR__, "fixtures/cat.jpg")
  @output_file Path.join(System.tmp_dir, "thumbnex-test-output.jpg")

  setup do
    tmp_copy = Mogrify.open(@fixture_image) |> Mogrify.copy

    on_exit fn ->
      File.cp tmp_copy.path, @fixture_image
    end
  end

  test "black image is smaller than cat image" do
    :ok = Thumbnex.create_thumbnail(@fixture_video, @output_file, time_offset: 0)
    %{size: black_size} = File.stat! @output_file

    :ok = Thumbnex.create_thumbnail(@fixture_video, @output_file, time_offset: 3)
    %{size: cat_size} = File.stat! @output_file

    assert black_size < cat_size
  end

  test "thumbnail of still image retains same dimensions" do
    %{width: width, height: height} = @fixture_image |> Mogrify.open |> Mogrify.verbose
    :ok = Thumbnex.create_thumbnail(@fixture_image, @output_file)
    assert %{width: ^width, height: ^height} = @output_file |> Mogrify.open |> Mogrify.verbose
  end

  test "max_width and max_height" do
    :ok = Thumbnex.create_thumbnail(@fixture_video, @output_file, max_width: 160, max_height: 160)
    assert %{width: "160", height: "120"} = @output_file |> Mogrify.open |> Mogrify.verbose
  end
end
