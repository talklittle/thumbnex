defmodule ThumbnexTest do
  use ExUnit.Case
  doctest Thumbnex

  @fixture_video Path.join(__DIR__, "fixtures/cat_fade_in.mp4")
  @fixture_image Path.join(__DIR__, "fixtures/cat.jpg")
  @fixture_gif   Path.join(__DIR__, "fixtures/cat_2frame.gif")
  @output_file   Path.join(System.tmp_dir, "thumbnex-test-output.jpg")
  @output_gif    Path.join(System.tmp_dir, "thumbnex-test-output.gif")

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
    assert %{width: 160, height: 120} = @output_file |> Mogrify.open |> Mogrify.verbose
  end

  test "preserve aspect when only one dimension specified, for still image" do
    :ok = Thumbnex.create_thumbnail(@fixture_image, @output_file, width: 150)
    assert %{width: 150, height: 100} = @output_file |> Mogrify.open |> Mogrify.verbose

    :ok = Thumbnex.create_thumbnail(@fixture_image, @output_file, height: 100)
    assert %{width: 150, height: 100} = @output_file |> Mogrify.open |> Mogrify.verbose
  end

  test "animated gif duration" do
    assert 1.0 == Thumbnex.Gifs.duration(@fixture_gif)
  end

  test "animated_gif_thumbnail/3 creates a GIF with 4 frames" do
    :ok = Thumbnex.animated_gif_thumbnail(@fixture_video, @output_gif)
    assert %{frame_count: 4} = @output_gif |> Mogrify.open |> Mogrify.verbose
  end

  test "optimized GIF has smaller filesize than unoptimized" do
    :ok = Thumbnex.animated_gif_thumbnail(@fixture_video, @output_gif, optimize: true)
    %{size: optimized} = File.stat! @output_gif

    :ok = Thumbnex.animated_gif_thumbnail(@fixture_video, @output_gif, optimize: false)
    %{size: unoptimized} = File.stat! @output_gif

    assert optimized < unoptimized
  end
end
