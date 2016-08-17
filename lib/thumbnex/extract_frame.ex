defmodule Thumbnex.ExtractFrame do
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

  defp temporary_file(ext) do
    random = :crypto.rand_uniform(100_000, 999_999_999_999)
    Path.join(System.tmp_dir, "thumbnex-#{random}#{ext}")
  end
end