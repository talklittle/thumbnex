defmodule Thumbnex.ExtractFrame do
  alias Thumbnex.Animations

  import FFmpex
  use FFmpex.Options

  @doc """
  Extract a single frame from the input file.

  Specify the time offset in seconds (0 for still images).

  Returns a tuple with :ok and the path of the single frame image file or :error and cmd output and exit status

  Options:

  * `:output_path` - Where to store the resulting file. Defaults to temporary file.
  * `:output_ext` - File extension for output. Ignored if `:output_path` is set. Defaults to `".png"`.
  """
  @spec single_frame(
          file_path :: binary(),
          time_offset_seconds :: non_neg_integer(),
          opts :: keyword()
        ) ::
          {:ok, binary()} | {:error, {Collectable.t(), exit_status :: non_neg_integer}}
  def single_frame(file_path, time_offset_seconds, opts \\ []) do
    output_ext = Keyword.get(opts, :output_ext, ".png")
    output_path = Keyword.get(opts, :output_path, temporary_file(output_ext))

    command =
      new_command()
      |> add_input_file(file_path)
      |> add_output_file(output_path)
      |> add_file_option(option_ss(time_offset_seconds))
      |> add_file_option(option_vframes(1))

    execute(command)
    |> case do
      {:ok, _} -> {:ok, output_path}
      res -> res
    end
  end

  @doc """
  Extract multiple frames from the input file.
  Specify the number of frames, and the frames per second, to output.

  Returns a tuple with :ok and the path of the output file (a single file containing multiple frames) or :error and the comd output and exit status

  Options:

  * `:output_path` - Where to store the resulting file. Defaults to temporary file.
  * `:output_ext` - File extension for output. Ignored if `:output_path` is set. Defaults to `".gif"`.
  """
  @spec multiple_frames(
          file_path :: binary(),
          frame_count :: non_neg_integer(),
          fps :: non_neg_integer(),
          opts :: keyword()
        ) ::
          {:ok, binary()} | {:error, {Collectable.t(), exit_status :: non_neg_integer}}
  def multiple_frames(file_path, frame_count, fps, opts \\ []) do
    output_ext = Keyword.get(opts, :output_ext, ".gif")
    output_path = Keyword.get(opts, :output_path, temporary_file(output_ext))

    Animations.duration(file_path)
    |> case do
      {:ok, original_duration} ->
        # use setpts filter to prevent output FPS from influencing which input frames are chosen
        secs_per_frame = original_duration / frame_count
        setpts_string = "setpts=PTS/#{secs_per_frame}/#{fps}"
        fps_string = "fps=#{fps}"
        vf_value = "#{setpts_string},#{fps_string}"

        command =
          new_command()
          |> add_input_file(file_path)
          |> add_output_file(output_path)
          |> add_file_option(option_vframes(frame_count))
          |> add_file_option(option_vf(vf_value))

        execute(command)
        |> case do
          {:ok, _} -> {:ok, output_path}
          res -> res
        end

      res ->
        res
    end
  end

  defp temporary_file(ext) do
    random = rand_uniform(999_999_999_999)
    Path.join(System.tmp_dir(), "thumbnex-#{random}#{ext}")
  end

  defp rand_uniform(high) do
    Code.ensure_loaded(:rand)

    if function_exported?(:rand, :uniform, 1) do
      :rand.uniform(high)
    else
      # Erlang/OTP < 19
      apply(:crypto, :rand_uniform, [1, high])
    end
  end
end
