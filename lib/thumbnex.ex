defmodule Thumbnex do
  @moduledoc """
  Create thumbnails from images and videos.
  """

  alias Thumbnex.ExtractFrame

  @doc """
  Create a thumbnail image.

  Image format is inferred from output path file extension.
  To override, pass the `:format` option.

  Options:

  * `:width` - Width of the thumbnail. Defaults to input width.
  * `:height` - Height of the thumbnail. Defaults to input height.
  * `:max_width` - Maximum width of the thumbnail.
  * `:max_height` - Maximum height of the thumbnail.
  * `:format` - Output format for the thumbnail. Defaults to infer from `output_path`.
  * `:time_offset` - Timestamp in seconds at which to take screenshot, for videos and GIFs.
    By default picks a time near the beginning, based on video duration.
  """
  @spec create_thumbnail(binary, binary, Keyword.t) :: :ok
  def create_thumbnail(input_path, output_path, opts \\ []) do
    input_path = Path.expand(input_path)
    output_path = Path.expand(output_path)

    max_width = number_opt(opts, :max_width, 1_000_000_000_000)
    max_height = number_opt(opts, :max_height, 1_000_000_000_000)
    format = Keyword.get(opts, :format, Path.extname(output_path))

    duration = duration(input_path)
    frame_time = number_opt(opts, :time_offset, frame_time(duration))

    image = input_path |> Mogrify.open |> Mogrify.verbose
    {width, _} = Float.parse(image.width)
    {height, _} = Float.parse(image.height)

    desired_width = number_opt(opts, :width, width)
    desired_height = number_opt(opts, :height, height)

    single_frame_path = ExtractFrame.single_frame(input_path, frame_time, output_ext: format)

    single_frame_path
    |> Mogrify.open
    |> Mogrify.verbose
    |> resize_if_different(desired_width, desired_height)
    |> Mogrify.resize_to_limit("#{max_width}x#{max_height}")
    |> Mogrify.save(path: output_path)

    File.rm! single_frame_path

    :ok
  end

  defp duration(input_path) do
    case FFprobe.duration(input_path) do
      :no_duration -> 0
      duration -> duration
    end
  end

  defp frame_time(short) when short < 4, do: 0
  defp frame_time(medium) when medium < 10, do: 1
  defp frame_time(long), do: 0.1 * long

  defp resize_if_different(image, desired_width, desired_height) do
    {width, _} = Float.parse(image.width)
    {height, _} = Float.parse(image.height)
    if width != desired_width or height != desired_height do
      image |> Mogrify.resize("#{desired_width}x#{desired_height}")
    else
      image
    end
  end

  defp number_opt(opts, key, default) do
    value = Keyword.get(opts, key)
    if is_number(value), do: value, else: default
  end
end
