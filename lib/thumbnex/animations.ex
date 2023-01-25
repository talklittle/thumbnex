defmodule Thumbnex.Animations do
  alias Thumbnex.Gifs

  @spec duration(file_path :: binary()) :: {:ok, any()} | {:error, any()}
  def duration(input_path) do
    FFprobe.format(input_path)
    |> case do
      {:ok, ffprobe_format} ->
        case FFprobe.duration(ffprobe_format) do
          :no_duration ->
            {:ok, format_names} = FFprobe.format_names(ffprobe_format)

            if "gif" in format_names do
              {:ok, Gifs.duration(input_path)}
            else
              {:ok, :no_duration}
            end

          duration ->
            {:ok, duration}
        end

      res ->
        res
    end
  end
end
