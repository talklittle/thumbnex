defmodule Thumbnex.Animations do

  alias Thumbnex.Gifs

  def duration(input_path) do
    {:ok, ffprobe_format} = FFprobe.format(input_path)
    case FFprobe.duration(ffprobe_format) do
      :no_duration ->
        if "gif" in FFprobe.format_names(ffprobe_format) do
          Gifs.duration(input_path)
        else
          :no_duration
        end

      duration -> duration
    end
  end

end