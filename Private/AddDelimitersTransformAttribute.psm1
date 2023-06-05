class AddDelimitersTransformAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object]$inputData)
    {
        if (!$inputData -is [string]) {
            return $inputData
        }
        
        if (!$inputData) {
            return $inputData
        }

        if ($inputData -notmatch '^\[' -and $inputData -notmatch ']$') {
            return "[$inputData]"
        }

        return $inputData
    }
}