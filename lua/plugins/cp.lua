return {
  'xeluxee/competitest.nvim',
  dependencies = 'MunifTanjim/nui.nvim',
  config = function()
    require('competitest').setup({
      testcases_use_single_file = false,

      -- naming scheme
      testcases_input_file_format = "$(TCNUM).in",
      testcases_output_file_format = "$(TCNUM).out",

      -- optional but useful
      save_current_file = true,
      evaluate_template_modifiers = true,
    })
  end,
}
