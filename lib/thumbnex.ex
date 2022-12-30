defmodule Thumbnex do
  @moduledoc """
  Create thumbnails from images and videos.
  """

  alias Thumbnex.Animations
  alias Thumbnex.ExtractFrame
  alias Thumbnex.Gifs

  @doc """
  Create a thumbnail image.

  Image format is inferred from output path file extension.
  To override, pass the `:format` option.

  Return tuple with :ok, nil value if everything goes well or :error, error output

  Options:

  * `:width` - Width of the thumbnail. Defaults to input width.
  * `:height` - Height of the thumbnail. Defaults to input height.
  * `:max_width` - Maximum width of the thumbnail.
  * `:max_height` - Maximum height of the thumbnail.
  * `:format` - Output format for the thumbnail. Defaults to `output_path` extension, or `"png"` if indeterminate.
  * `:time_offset` - Timestamp in seconds at which to take screenshot, for videos and GIFs.
    By default picks a time near the beginning, based on video duration.
  """
  @spec create_thumbnail(binary, binary, Keyword.t()) ::
          {:ok, nil} | {:error, {Collectable.t(), exit_status :: non_neg_integer}}
  def create_thumbnail(input_path, output_path, opts \\ []) do
    input_path = Path.expand(input_path)
    output_path = Path.expand(output_path)

    max_width = number_opt(opts, :max_width, 1_000_000_000_000)
    max_height = number_opt(opts, :max_height, 1_000_000_000_000)
    format = normalize_format(Keyword.get(opts, :format, image_format_from_path(output_path)))

    Animations.duration(input_path)
    |> case do
      {:ok, duration} ->
        frame_time = number_opt(opts, :time_offset, frame_time(duration))

        desired_width = number_opt(opts, :width, nil)

        desired_height = number_opt(opts, :height, nil)

        ExtractFrame.single_frame(input_path, frame_time, output_ext: ".#{format}")
        |> case do
          {:ok, single_frame_path} ->
            single_frame_path
            |> Mogrify.open()
            |> Mogrify.verbose()
            |> resize_if_different(desired_width, desired_height)
            |> Mogrify.resize_to_limit("#{max_width}x#{max_height}")
            |> Mogrify.save(path: output_path)

            File.rm(single_frame_path)
            |> case do
              :ok ->
                {:ok, nil}

              res ->
                res
            end

          res ->
            res
        end

      res ->
        res
    end
  end

  @doc """
  Create an animated GIF preview.

  Options:

  * `:width` - Width of the thumbnail. Defaults to input width.
  * `:height` - Height of the thumbnail. Defaults to input height.
  * `:max_width` - Maximum width of the thumbnail.
  * `:max_height` - Maximum height of the thumbnail.
  * `:frame_count` - Number of frames to output. Default 4.
  * `:fps` - Frames per second of output GIF. Default 1.
  * `:optimize` - Add mogrify options to reduce output size. Default true.
  """
  @spec animated_gif_thumbnail(binary, binary, Keyword.t()) ::
          :ok | {:error, {Collectable.t(), exit_status :: non_neg_integer}}
  def animated_gif_thumbnail(input_path, output_path, opts \\ []) do
    input_path = Path.expand(input_path)
    output_path = Path.expand(output_path)

    max_width = number_opt(opts, :max_width, 1_000_000_000_000)
    max_height = number_opt(opts, :max_height, 1_000_000_000_000)
    desired_width = number_opt(opts, :width, nil)
    desired_height = number_opt(opts, :height, nil)
    frame_count = number_opt(opts, :frame_count, 4)
    fps = number_opt(opts, :fps, 1)
    optimize = Keyword.get(opts, :optimize, true)

    ExtractFrame.multiple_frames(input_path, frame_count, fps, output_ext: ".gif")
    |> case do
      {:ok, multi_frame_path} ->
        multi_frame_path
        |> Mogrify.open()
        |> Mogrify.verbose()
        |> resize_if_different(desired_width, desired_height)
        |> Mogrify.resize_to_limit("#{max_width}x#{max_height}")
        |> optimize_mogrify_image(optimize)
        |> Mogrify.save(path: output_path)

        File.rm(multi_frame_path)
        |> case do
          :ok ->
            {:ok, nil}

          res ->
            res
        end

      res ->
        res
    end
  end

  defp image_format_from_path(path) do
    case Path.extname(path) do
      "" -> "png"
      # remove "."
      extname -> String.slice(extname, 1..-1)
    end
  end

  defp normalize_format(format) do
    if String.starts_with?(format, "."), do: String.slice(format, 1..-1), else: format
  end

  defp frame_time(:no_duration), do: 0
  defp frame_time(short) when short < 4, do: 0
  defp frame_time(medium) when medium < 10, do: 1
  defp frame_time(long), do: 0.1 * long

  defp resize_if_different(image, nil, nil), do: image

  defp resize_if_different(%{width: width, height: height} = image, desired_width, desired_height) do
    if width != desired_width or height != desired_height do
      image |> Mogrify.resize("#{desired_width}x#{desired_height}")
    else
      image
    end
  end

  defp optimize_mogrify_image(image, true = _optimize) do
    Gifs.optimize_mogrify_image(image)
  end

  defp optimize_mogrify_image(image, false = _optimize), do: image

  defp number_opt(opts, key, default) do
    value = Keyword.get(opts, key)
    if is_number(value), do: value, else: default
  end
end
