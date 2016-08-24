defmodule Thumbnex.ExtractFrame do

  alias Thumbnex.Animations

  import FFmpex
  import FFmpex.Options.Main
  import FFmpex.Options.Video

  @doc """
  Extract a single frame from the input file.
  Specify the time offset in seconds (0 for still images).

  Returns the path of the single frame image file.

  Options:

  * `:output_path` - Where to store the resulting file. Defaults to temporary file.
  * `:output_ext` - File extension for output. Ignored if `:output_path` is set. Defaults to `".png"`.
  """
  def single_frame(file_path, time_offset_seconds, opts \\ []) do
    output_ext = Keyword.get(opts, :output_ext, ".png")
    output_path = Keyword.get(opts, :output_path, temporary_file(output_ext))

    command =
      new_command
      |> add_input_file(file_path)
      |> add_output_file(output_path)
        |> add_file_option(option_ss(time_offset_seconds))
        |> add_file_option(option_vframes(1))
    {_, 0} = execute(command)

    output_path
  end

  @doc """
  Extract multiple frames from the input file.
  Specify the number of frames, and the frames per second, to output.

  Returns the path of the output file, a single file containing multiple frames.

  Options:

  * `:output_path` - Where to store the resulting file. Defaults to temporary file.
  * `:output_ext` - File extension for output. Ignored if `:output_path` is set. Defaults to `".gif"`.
  """
  def multiple_frames(file_path, frame_count, fps, opts \\ []) do
    output_ext = Keyword.get(opts, :output_ext, ".gif")
    output_path = Keyword.get(opts, :output_path, temporary_file(output_ext))

    original_duration = Animations.duration(file_path)

    command =
      new_command
      |> add_input_file(file_path)
      |> add_output_file(output_path)
        |> add_file_option(option_vframes(frame_count))
        |> add_file_option(option_vf(fps_string(frame_count, fps, original_duration)))
    {_, 0} = execute(command)

    output_path
  end

  defp fps_string(_frame_count, fps, :no_duration), do: "fps=#{fps}"
  defp fps_string(frame_count, fps, original_duration) do
    "fps=#{fps}*#{frame_count}/#{original_duration}"
  end

  defp temporary_file(ext) do
    random = :crypto.rand_uniform(100_000, 999_999_999_999)
    Path.join(System.tmp_dir, "thumbnex-#{random}#{ext}")
  end
end