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

    # use setpts filter to prevent output FPS from influencing which input frames are chosen
    secs_per_frame = original_duration / frame_count
    setpts_string = "setpts=PTS/#{secs_per_frame}/#{fps}"
    fps_string = "fps=#{fps}"
    vf_value = "#{setpts_string},#{fps_string}"

    command =
      new_command
      |> add_input_file(file_path)
      |> add_output_file(output_path)
        |> add_file_option(option_vframes(frame_count))
        |> add_file_option(option_vf(vf_value))
    {_, 0} = execute(command)

    output_path
  end

  defp temporary_file(ext) do
    random = :crypto.rand_uniform(100_000, 999_999_999_999)
    Path.join(System.tmp_dir, "thumbnex-#{random}#{ext}")
  end
end