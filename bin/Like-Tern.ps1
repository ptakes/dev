function Like-Tern {
   $Colon = 0
   for ($Index = 1; $Index -lt $args.Count; $Index++) {
      if ($args[$Index] -eq ":") {
         $Colon = $Index
         break
      }
   }

   if ($Colon -eq 0) { 
      throw new System.Exception "No operator!" 
   }

   if ($args[$Colon - 1] -eq $null -or $args[$Colon - 1] -eq "") {
      $args[$Colon + 1]
   }
   else  {
      $args[$Colon - 1]
   }
}

Set-Alias ~ Like-Tern -Option AllScope
