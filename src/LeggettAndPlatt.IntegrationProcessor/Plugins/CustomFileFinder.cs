using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace LeggettAndPlatt.IntegrationProcessor.Plugins
{
    public class CustomFileFinder
    {
        public IList<string> GetFiles(string path, IList<string> filePatterns)
        {
            List<string> source1 = new List<string>();
            var directories = Directory.GetDirectories(path);
            foreach (string directory in directories)
            {
                foreach (string filePattern1 in (IEnumerable<string>)filePatterns)
                {
                    try
                    {
                        string filePattern2 = this.GetFilePattern(filePattern1);
                        Regex regex = this.GetPatternRegex(filePattern2);
                        IEnumerable<string> source2 = Directory.EnumerateFiles(this.GetPath(directory, filePattern1), filePattern2);
                        source1.AddRange(source2.Where<string>((Func<string, bool>)(o => regex.IsMatch(Path.GetFileName(o) ?? string.Empty))));
                    }
                    catch (DirectoryNotFoundException ex)
                    {
                    }
                }
            }

            return (IList<string>)source1.Distinct<string>((IEqualityComparer<string>)StringComparer.OrdinalIgnoreCase).ToList<string>();
        }

        /// <summary>The get pattern regex.</summary>
        /// <param name="filePattern">The file pattern.</param>
        /// <returns>The <see cref="T:System.Text.RegularExpressions.Regex" />.</returns>
        protected Regex GetPatternRegex(string filePattern)
        {
            return new Regex("^" + Regex.Escape(filePattern).Replace("\\*", ".*").Replace("\\?", ".") + "$", RegexOptions.IgnoreCase | RegexOptions.Compiled);
        }

        /// <summary>The get file pattern.</summary>
        /// <param name="filePattern">The file pattern.</param>
        /// <returns>The <see cref="T:System.String" />.</returns>
        protected string GetFilePattern(string filePattern)
        {
            return ((IEnumerable<string>)filePattern.Split(new char[2]
            {
        '/',
        '\\'
            }, StringSplitOptions.RemoveEmptyEntries)).Last<string>();
        }

        /// <summary>Get the path with any subdirectories specified in the file pattern provided.</summary>
        /// <param name="path">The base file path.</param>
        /// <param name="filePattern">The file pattern.</param>
        /// <returns>The full path.</returns>
        protected string GetPath(string path, string filePattern)
        {
            string[] strArray = filePattern.Split(new char[2]
            {
        '/',
        '\\'
            }, StringSplitOptions.RemoveEmptyEntries);
            return ((IEnumerable<string>)strArray).Take<string>(((IEnumerable<string>)strArray).Count<string>() - 1).Aggregate<string, string>(path, (Func<string, string, string>)((current, pathPart) => Path.Combine(current + "\\", pathPart)));
        }
    }
}
